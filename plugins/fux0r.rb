class Fux0r
  include Cinch::Plugin
  
  match /fux0r( stats)?$/, method: :stats
  #match /fux0r freeleech$/, method: :freeleech
  
  def stats(m)
    return unless is_configured?(m.user)
    user = USERS[m.user.nick.downcase]
    
    a = Mechanize.new
    a.get('https://ssl.fux0r.eu/login.php') do |page|
      # Submit login page
      idx_page = page.form_with(:action => "login.php") do |f|
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
  
=begin
  def freeleech(m)
    user = USERS[m.user.nick.downcase]
    
    a = Mechanize.new
    a.get('https://ssl.fux0r.eu/login.php') do |page|
      # Submit login page
      idx_page = page.form_with(:action => "login.php") do |f|
        f.username = user[1]
        f.password = user[2]
      end.submit
      search_page = a.click(idx_page.link_with(:href => "torrents.php"))
      print search_page.inspect
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
=end
  
  listen_to :help, method: :help
  def help(m)
    m.reply("!fux0r stats (!fux0r) - Retrieve your statistics from Fux0r.eu")
    #m.reply("!what freeleech (!freeleech) - Display the last 5 freeleech albums from What.CD")
  end
end