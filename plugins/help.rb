class Help
  include Cinch::Plugin

  match 'help'
  def execute(m)
    m.reply("This is the help documentation\n!help will display this info")
    @bot.dispatch(:help, m)
  end
end