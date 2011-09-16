class User
  include DataMapper::Resource

  property(:id,         Serial)
  property(:name,       String, :unique => true)
  property(:email,      String, :unique => true)
  property(:password,   String)
  property(:rank,       Integer, :default => 0)
end

def is_logged_in?(m)
  return ($logged_in.has_key?(m.user.authname) ? $logged_in[m.user.authname] : false) unless m.user.authname.nil?
  return false
end

def is_admin?(m)
  if (user = is_logged_in?(m)) != false
    return user.rank == 1
  end
  return false
end

module SavageBot
  module Plugins
    class Users
      include Cinch::Plugin
      
      def initialize(*args)
        super
        
        $logged_in = {}
        @admin_key = Array.new(16) { rand(256) }.pack('C*').unpack('H*').first
        print "\n\nAdmin key is #{@admin_key}\n\n"
      end
    
      match /register ([^\s]+) (.+)/, method: :register
      match /login (.+)/, method: :login
      match 'logout', method: :logout
      match /rank (.+) ([01]) ([a-zA-Z0-9]{32})/, method: :rank
      
      def register(m, email, password)
        if m.user.authname.nil?
          return m.reply('Please authenticate with nickserv before registering with SavageBot')
        end
        return m.reply("You're already signed in as #{m.user.authname}") if is_logged_in?(m)
        if User.first(:name => m.user.authname).nil? == false
          return m.reply("That authenticated name (#{m.user.authname}) is already registered")
        end
        
        $logged_in[m.user.authname] = User.create(
          :name     => m.user.authname,
          :email    => email,
          :password => password
        )
        
        m.reply("You have now registered #{m.user.authname} to #{email}")
      end
      
      def login(m, password)
        return m.reply("You're already signed in as #{m.user.authname}") if is_logged_in?(m)
        if (user = User.first(:name => m.user.authname, :password => password)).nil?
          return m.reply("Those are the wrong credentials for signing into #{m.user.authname}")
        end
        $logged_in[m.user.authname] = user
        
        m.reply("You have signed in as #{m.user.authname}")
      end
      
      def logout(m)
        return m.reply("You're not signed in as #{m.user.authname} right now") if is_logged_in?(m) == false
        $logged_in.delete(m.user.authname)
        m.reply("You're no longer signed in as #{m.user.authname}")
      end
      
      def rank(m, user, level, key)
        return unless key == @admin_key || is_admin?(m)
        return m.reply("#{user} has not registered with Savage before") if (user = User.first(:name => user)).nil?
        user.rank = level
        user.save
        m.reply("#{user.name} is now a" + (level == '0' ? ' user' : 'n admin'))
      end
      
      listen_to :help, method: :help
      def help(m)
        m.user.send("!register email@address.com password - Register your current nickname with a Savage account\n" +
                    "!login password - Log in to the Savage account connected to your current nickname\n" +
                    "!logout - Log out of the Savage account that you're signed into")
        return unless is_admin?(m)
        m.user.send("!rank username [0|1] (key) - Change a user's rank (0=user, 1=admin). The key is currently #{@admin_key}")
      end
    end
  end
end