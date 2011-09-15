class Impersonation
  include Cinch::Plugin

  match /impersonation pranking( #[a-zA-Z0-9]+)? (.+)/
  def execute(m, channel, message)
    return unless is_admin?(m.user)
    channel ||= '#SavageBot'
    Channel(channel.strip).send(message)
  end
end