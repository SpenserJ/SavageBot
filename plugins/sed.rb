module SavageBot
  module Plugins
    class SED
      include Cinch::Plugin
      
      SED_REGEX = /s\/(.*)\/(.*)\/(i)?/
      
      listen_to :channel
      
      def listen(m)
        return if (match = m.message.match(SED_REGEX)).nil?
        return if (messages = LoggedMessage.all(:username => m.user.nick, :channel => m.channel.name, :order => [:created_at.desc], :limit => 3)).nil?
        regex = Regexp.new(match[1], (match[3].nil? == false))
        messages.each { |message|
          return m.reply(message.message.gsub(regex, match[2]), true) if message.message.match(SED_REGEX).nil? && message.message.match(regex)
        }
        m.reply('No matches were found', true)
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