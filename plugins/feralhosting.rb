require 'net/https'
require 'json'

class AccountFeralHosting
  include DataMapper::Resource

  property(:id,         Serial)
  property(:username,   String, :unique => true)
  
  belongs_to :user
end

def feral_api(m, request)
  return m.reply("Please connect your FeralHosting account first") unless (user = is_logged_in?(m)) != false && (user = AccountFeralHosting.first(:user => user)).nil? == false
  uri = URI.parse("https://www.feralhosting.com/api/json/0.3/#{user.username}/#{request}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth FERALHOSTING[0], FERALHOSTING[1]
  response = http.request(req)
  JSON.parse(response.body)['response']['0']
end

module SavageBot
  module Plugins
    class FeralHosting
      include Cinch::Plugin
      
      match /(feral )?hdd$/, method: :hdd
      match /(feral )?bandwidth$/, method: :bandwidth
      match /feral link (.+)/, method: :link
      match /feral unlink/, method: :unlink
      
      def hdd(m)
        return unless is_configured?(m.user)
        json = feral_api(m, 'server/disk')
        m.reply "#{m.user.nick}: You have used " + (json['kilobytes'].to_f / 1024 / 1024).round(2).to_s + ' GB of HDD space'
      end
      
      def bandwidth(m)
        return unless is_configured?(m.user)
        json = feral_api(m, 'server/bandwidth')
        m.reply "#{m.user.nick}: You have uploaded " + (json['upload-external-bytes'].to_f / 1024 / 1024 / 1024).round(2).to_s + ' GB'
      end
      
      def link(m, username)
        return m.reply("Please sign into Savage first") unless (user = is_logged_in?(m)) != false
        return m.reply("That FeralHosting account is already linked") if AccountFeralHosting.first(:username => username).nil? == false
        AccountFeralHosting.create(:username => username, :user => user)
        m.reply("Credentials have been saved for your FeralHosting account")
      end
      
      def unlink(m)
        return m.reply("Please sign into Savage first") unless (user = is_logged_in?(m)) != false
        return m.reply("There is no FeralHosting account linked to #{m.user.authname}") if (link = AccountFeralHosting.first(:user => user)).nil?
        link.destroy
        m.reply("That FeralHosting account has been unlinked from #{m.user.authname}")
      end
      
      listen_to :help, method: :help
      def help(m)
        m.user.send("!feral hdd (!hdd) - Retrieve your HDD usage from FeralHosting\n" +
                    "!feral bandwidth (!bandwidth) - Retrieve your bandwidth usage from FeralHosting\n" +
                    "!feral link username - Connect your Savage account to a FeralHosting account\n" +
                    "!feral unlink - Break the connection between your Savage account and FeralHosting account")
      end
    end
  end
end