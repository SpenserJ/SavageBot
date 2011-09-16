class Administration
  include Cinch::Plugin

  match /join(?: (.+))?/, method: :join
  match /part(?: (.+))?/, method: :part
  match 'shutdown', method: :shutdown
  match 'restart', method: :restart
  match /invite(?: (.+))?/, method: :invite

  def join(m, channel)
    return unless is_admin?(m)
    channel ||= '#SavageBot'
    Channel(channel).join
  end

  def part(m, channel)
    return unless is_admin?(m)
    m.channel.topic = TOPIC + ' :: Savage [Offline]'
    channel ||= m.channel
    Channel(channel).part if channel
  end
  
  def shutdown(m)
    return unless is_admin?(m)
    m.channel.topic = TOPIC + ' :: Savage [Offline]'
    exit
  end
  
  def restart(m)
    return unless is_admin?(m)
    m.channel.topic = TOPIC + ' :: Savage [Offline]'
    `ruby bot.rb &`
    exit
  end
  
  def invite(m, nick)
    return unless is_admin?(m) || is_configured?(m.user)
    nick ||= m.user.nick
    bot.raw('invite ' + nick.strip + ' #SavageBot')
  end
  
  listen_to :help, method: :help
  def help(m)
    m.reply("!invite (username) - Invite a user into #SavageBot")
    if is_admin?(m)
      m.reply("!join (channel) - Tell SavageBot to join a channel (Defaults to #SavageBot)")
      m.reply("!part (channel) - Tell SavageBot to part a channel (Defaults to current)")
      m.reply("!shutdown - Shutdown SavageBot cleanly")
      m.reply("!restart - Restart SavageBot cleanly")
    end
  end
end