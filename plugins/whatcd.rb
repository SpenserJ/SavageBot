require 'mechanize'

class AccountWhatCD
  include DataMapper::Resource

  property(:id,         Serial)
  property(:username,   String, :unique => true)
  property(:password,   String)
  
  belongs_to :user
end

module SavageBot
  module Plugins
    class WhatCD
      include Cinch::Plugin
      
      match /what( stats)?$/, method: :stats
      match /(what )?freeleech$/, method: :freeleech
      match /what link (.+) (.+)/, method: :link
      match /what unlink/, method: :unlink
      
      def stats(m)
        return m.reply("Please connect your What.CD account first") unless (user = is_logged_in?(m)) != false && (user = AccountWhatCD.first(:user => user)).nil? == false
        a = Mechanize.new
        a.get('https://ssl.what.cd/') do |page|
          # Click login link
          login_page = a.click(page.link_with(:text => "Login"))
          # Submit login page
          idx_page = login_page.form_with(:action => "login.php") do |f|
            f.username = user.username
            f.password = user.password
          end.submit
          stats = []
          idx_page.search('#userinfo_stats li').each { |stat|
            stats.push(stat.children[0].content.gsub(':', '') + ': ' + stat.search('span')[0].content)
          }
          m.reply "#{m.user.nick}: " + stats.join(', ')
        end
      end
      
      def freeleech(m)
        return m.reply("Please connect your What.CD account first") unless (user = is_logged_in?(m)) != false && (user = AccountWhatCD.first(:user => user)).nil? == false
        
        a = Mechanize.new
        a.get('https://ssl.what.cd/login.php') do |page|
          # Submit login page
          idx_page = page.form_with(:action => "login.php") do |f|
            f.username = user.username
            f.password = user.password
          end.submit
          search_page = a.click(idx_page.link_with(:href => "torrents.php"))
          search_page = a.click(search_page.link_with(:href => "torrents.php?action=advanced&"))
          results_page = search_page.form_with(:name => "filter") do |f|
            f.freetorrent = 1
          end.submit
          freeleech = []
          torrents = results_page.search('#torrent_table tr.group')[0..4].each { |album|
            freeleech.push(album.search('td')[2].children[0, 5].inner_text().strip)
          }
          m.reply "Recent freeleeches: " + freeleech.join(", ")
        end
      end
      
      def link(m, username, password)
        return m.reply("Please sign into Savage first") unless (user = is_logged_in?(m)) != false
        return m.reply("That What.CD account is already linked") if AccountWhatCD.first(:username => username).nil? == false
        AccountWhatCD.create(:username => username, :password => password, :user => user)
        m.reply("Credentials have been saved for your What.CD account")
      end
      
      def unlink(m)
        return m.reply("Please sign into Savage first") unless (user = is_logged_in?(m)) != false
        return m.reply("There is no What.CD account linked to #{m.user.authname}") if (link = AccountWhatCD.first(:user => user)).nil?
        link.destroy
        m.reply("That What.CD account has been unlinked from #{m.user.authname}")
      end
      
      listen_to :help, method: :help
      def help(m)
        m.reply("!what stats (!what) - Retrieve your statistics from What.CD")
        m.reply("!what freeleech (!freeleech) - Display the last 5 freeleech albums from What.CD")
        m.reply("!what link username password - Connect your Savage account to a What.CD account")
        m.reply("!what unlink - Break the connection between your Savage account and What.CD account")
      end
    end
  end
end