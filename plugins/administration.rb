module SavageBot
  module Plugins
    class Administration
      include Cinch::Plugin
    
      match /join(?: (.+))?/, method: :join
      match /part( [^\s]+)?( .+)?/, method: :part
      match 'shutdown', method: :admin_shutdown
      match /invite(?: (.+))?/, method: :invite
    
      def join(m, channel)
        return unless is_admin?(m)
        channel = '#SavageBot' if channel.nil?
        Channel(channel).join
      end
    
      def part(m, channel, message)
        return unless is_admin?(m)
        if channel.nil? == false
          channel = Channel(channel.strip)
        else
          channel = m.channel if channel.nil?
        end
        m.channel.topic = TOPIC + ' :: Savage [Offline]'
        print message.inspect
        message = 'Mommy said "If you can\'t say anything nice, don\'t say anything at all!", so with that, I\'m leaving!' if message.nil?
        print message.inspect
        channel.part(message.strip) if channel
      end
      
      def admin_shutdown(m)
        return unless is_admin?(m)
        shutdown
      end
      
      def invite(m, nick)
        return unless is_admin?(m) || is_logged_in?(m) != false
        nick ||= m.user.nick
        bot.raw('invite ' + nick.strip + ' #SavageBot')
      end
      
      listen_to :help, method: :help
      def help(m)
        m.user.send("!invite (username) - Invite a user into #SavageBot")
        if is_admin?(m)
          m.user.send("!join (channel) - Tell SavageBot to join a channel (Defaults to #SavageBot)\n" +
                      "!part (channel) (part message) - Tell SavageBot to part a channel (Defaults to current)\n" +
                      "!shutdown - Shutdown SavageBot cleanly")
        end
      end
    end
  end
end