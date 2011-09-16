Dir.chdir File.dirname(__FILE__) # If we're running as a daemon, make sure we're in the right dir
require 'cinch'
require "dm-core"
require "dm-types"
require "dm-migrations"
require './accounts.rb'
Dir['./plugins/*.rb'].each {|file| require file }

TOPIC = 'Welcome to SavageBot. IRC bot for FeralHosting and ruTorrent'
VERSION = 0.1
DBFILE = Dir.getwd + "/sqlite.db"
ADMINS = ["brilliantwinter", "makeshift"]

# Database
DataMapper.setup(:default, "sqlite3:///" + DBFILE)

# If database doesn't exist, create. Else update
if(!File.exists?(DBFILE))
  DataMapper.auto_migrate!
elsif(File.exists?(DBFILE))
  DataMapper.auto_upgrade!
end

@bot = bot = Cinch::Bot.new do |bot|
  configure do |c|
    c.plugins.plugins  = [SavageBot::Plugins::WhatCD,
                          SavageBot::Plugins::Fux0r,
                          SavageBot::Plugins::FeralHosting,
                          SavageBot::Plugins::Administration,
                          SavageBot::Plugins::DownForEveryone,
                          BasicCTCP,
                          Plugins::MultiQDB,
                          Plugins::Scores,
                          SavageBot::Plugins::UrbanDictionary,
                          SavageBot::Plugins::Impersonation,
                          SavageBot::Plugins::Users,
                          SavageBot::Plugins::Help]
    
    c.server = "irc.what-network.net"
    c.nick = c.realname = c.user = IRC[0]
    c.messages_per_second = 2
  end
  
  on :connect do |m|
    print 'Connected ' + m.inspect
    User('NickServ').send('identify ' + IRC[1])
    User('ChanServ').send('invite #SavageBot')
  end
  
  on :invite do |m|
    m.channel.join
  end
  
  on :join do |m|
    if m.channel.name == '#SavageBot' && m.user.nick == bot.nick
      m.channel.topic = TOPIC + ' :: Savage [Online]'
    end
  end
end

def shutdown
  @bot.channels.each { |channel|
    channel.topic = TOPIC + ' :: Savage [Offline]' if channel.name == '#SavageBot'
    channel.part("My master is trying to kill me! Someone call 911!")
  }
  @bot.plugins.each { |p| p.shutdown if p.respond_to?('shutdown') }
  sleep(5)
  exit
end

trap("INT")  do; shutdown; end
trap("KILL") do; shutdown; end

bot.start