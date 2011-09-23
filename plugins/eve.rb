require 'net/https'
require 'json'

class AccountEveAPI
  include DataMapper::Resource
  
  property(:id, Serial)
  property(:userid, String, :unique => true)
  property(:apikey, String)
  
  belongs_to :user
end

def eve_api(user)
  uri = URI.parse("https://api.eveonline.com/account/AccountStatus.xml.aspx?userID=#{user.userid}&apiKey=#{user.apikey}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
  req = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(req)
  xml = Nokogiri::XML(response.body)
  date = xml.xpath('//paidUntil')[0].children[0].content
end

module SavageBot
  module Plugins
    class EveAPI
      include Cinch::Plugin
      
      match /eve check$/, method: :check
      match /eve link (.+) (.+)/, method: :link
      match /eve unlink/, method: :unlink
      match /eve help/, method: :help
      
      def check(m)
        return m.reply("Please connect your Eve API  first, call !eve help") unless (user = is_logged_in?(m)) != false && (user = AccountEveAPI.first(:user => user)).nil? == false
        date = eve_api(user)
        m.reply("#{m.user.nick}: Eve account paid until: #{date}")
      end
      
      def link(m, userid, apikey)
        return m.reply("Please sign into Savage first") unless (user = is_logged_in?(m)) != false
        return m.reply("That id is already linked to an account") if AccountEveAPI.first(:userid => userid).nil? == false
        AccountEveAPI.create(:userid => userid, :apikey => apikey, :user => user)
        m.reply("Credentials have been saved for your Eve API")
      end
      
      def unlink(m)
        return m.reply("Please sign into Savage first") unless (user = is_logged_in?(m)) != false
        return m.reply("There is no Eve API linked to #{m.user.authname}") if (link = AccountEveAPI.first(:user => user)).nil?
        link.destroy
        m.reply("Eve API has been unlinked from #{m.user.authname}")
      end
      
      listen_to :help, method: :help
      def help(m)
        m.user.send("!eve check - Retrieve date your account expires\n" +
                    "!eve link userid apikey - Connect your Savage account to your Eve API\n" +
                    "!eve unlink - Break the connection between your Savage account and Eve API")
      end
    end
  end
end