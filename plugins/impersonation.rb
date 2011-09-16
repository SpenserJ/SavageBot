module SavageBot
  module Plugins
    class Impersonation
      include Cinch::Plugin
    
      match /impersonation (#[a-zA-Z0-9]+) (.+)/
      def execute(m, channel, message)
        return unless is_admin?(m)
        Channel(channel.strip).send(message)
      end
      
      listen_to :help, method: :help
      def help(m)
        return unless is_admin?(m)
        m.user.send("!impersonation #channel message - Send a message from SavageBot's account")
      end
    end
  end
end