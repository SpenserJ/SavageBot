require 'dm-timestamps'

class LoggedMessage
  include DataMapper::Resource

  property(:id,         Serial)
  property(:channel,   String)
  property(:username,   String)
  property(:message,    String)
  property(:created_at, DateTime)
end

module SavageBot
  module Plugins
    class Log
      include Cinch::Plugin
      
      listen_to :channel
      
      def listen(m)
        return if m.channel.nil? || m.user.nil?
        LoggedMessage.create(:channel => m.channel.name,
                             :username => m.user.nick,
                             :message => m.message)
      end
      
      listen_to :help, method: :help
      def help(m)
        #m.user.send("!what stats (!what) - Retrieve your statistics from What.CD\n" +
        #            "!what freeleech (!freeleech) - Display the last 5 freeleech albums from What.CD\n" +
        #            "!what link username - Connect your Savage account to a What.CD account\n" +
        #            "!what unlink - Break the connection between your Savage account and What.CD account")
      end
    end
  end
end