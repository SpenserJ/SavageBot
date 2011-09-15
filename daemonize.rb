require 'daemons'
Daemons.run('bot.rb', {
  :monitor    => true
})