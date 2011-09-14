require 'cinch'
require 'json'
require 'net/https'
require 'mechanize'
require './accounts.rb'
Dir['./plugins/*.rb'].each {|file| require file }

TOPIC = 'Welcome to SavageBot. IRC bot for FeralHosting and ruTorrent'

def is_admin?(user)
  user.refresh # be sure to refresh the data, or someone could steal the nick
  @admins.include?(user.authname.downcase) if user.authname.nil? == false
end

def is_configured?(user)
  user.refresh # be sure to refresh the data, or someone could steal the nick
  USERS.include?(user.authname.downcase) if user.authname.nil? == false
end

bot = Cinch::Bot.new do |bot|
  configure do |c|
    c.server = "irc.what-network.net"
    c.nick = c.realname = c.user = 'SavageBot'
    
    c.plugins.plugins  = [WhatCD, Fux0r, FeralHosting, Administration, Help]
  end
  
  on :connect do |m|
    print 'Connected ' + m.inspect
    User('NickServ').send('identify 2022120003')
    Channel('#SavageBot').join
  end
  
  on :join do |m|
    if m.channel.name == '#SavageBot' && m.user.nick == bot.nick
      m.channel.topic = TOPIC + ' :: Savage [Online]'
    end
  end
end

bot.start