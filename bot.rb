Dir.chdir File.dirname(__FILE__) # If we're running as a daemon, make sure we're in the right dir
require 'cinch'
require 'json'
require 'net/https'
require 'mechanize'
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

bot = Cinch::Bot.new do |bot|
  configure do |c|
    c.plugins.plugins  = [WhatCD,
                          Fux0r,
                          FeralHosting,
                          Administration,
                          DownForEveryone,
                          BasicCTCP,
                          Plugins::MultiQDB,
                          Plugins::Scores,
                          Plugins::UrbanDictionary,
                          Impersonation,
                          SavageBot::Plugins::Users,
                          Help]
    
    c.server = "irc.what-network.net"
    c.nick = c.realname = c.user = IRC[0]
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

bot.start