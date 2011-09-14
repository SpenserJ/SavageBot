class WhatCD
  include Cinch::Plugin
  
  match /what( stats)?$/, method: :stats
  match /(what )?freeleech$/, method: :freeleech
  
  def stats(m)
    return unless is_configured?(m.user)
    user = USERS[m.user.nick.downcase]
    
    a = Mechanize.new
    a.get('https://ssl.what.cd/') do |page|
      # Click login link
      login_page = a.click(page.link_with(:text => "Login"))
      # Submit login page
      idx_page = login_page.form_with(:action => "login.php") do |f|
        f.username = user[1]
        f.password = user[2]
      end.submit
      stats = []
      idx_page.search('#userinfo_stats li').each { |stat|
        stats.push(stat.children[0].content.gsub(':', '') + ': ' + stat.search('span')[0].content)
      }
      m.reply "#{m.user.nick}: " + stats.join(', ')
    end
  end
  
  def freeleech(m)
    return unless is_configured?(m.user)
    user = USERS[m.user.nick.downcase]
    
    a = Mechanize.new
    a.get('https://ssl.what.cd/login.php') do |page|
      # Submit login page
      idx_page = page.form_with(:action => "login.php") do |f|
        f.username = user[1]
        f.password = user[2]
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
  
  listen_to :help, method: :help
  def help(m)
    m.reply("!what stats (!what) - Retrieve your statistics from What.CD")
    m.reply("!what freeleech (!freeleech) - Display the last 5 freeleech albums from What.CD")
  end
end