class User
  include DataMapper::Resource

  property(:id,         Serial)
  property(:name,       String, :unique => true)
  property(:email,      String, :unique => true)
  property(:password,   String)
  property(:rank,       Integer, :default => 0)
end

def is_logged_in?(m)
  return ($logged_in.has_key?(m.user.authname) ? $logged_in[m.user.authname] : false)
end

module SavageBot
  module Plugins
    class Users
      include Cinch::Plugin
      
      def initialize(*args)
        super
        
        $logged_in = {}
      end
    
      match /register ([^\s]+) (.+)/, method: :register
      match /login (.+)/, method: :login
      match 'logout', method: :logout
      
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
    end
  end
end