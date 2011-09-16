class AccountFux0r
  include DataMapper::Resource

  property(:id,         Serial)
  property(:username,   String, :unique => true)
  property(:password,   String)
  
  belongs_to :user
end

class Fux0r
  include Cinch::Plugin
  
  match /fux0r( stats)?$/, method: :stats
  match /fux0r freeleech$/, method: :freeleech
  match /fux0r link (.+) (.+)/, method: :link
  match /fux0r unlink/, method: :unlink
  
  def stats(m)
    return m.reply("Please connect your Fux0r account first") unless (user = is_logged_in?(m)) != false && (user = AccountFux0r.first(:user => user)).nil? == false
    
    a = Mechanize.new
    a.get('https://ssl.fux0r.eu/login.php') do |page|
      # Submit login page
      idx_page = page.form_with(:action => "login.php") do |f|
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
    return m.reply("Please connect your Fux0r account first") unless (user = is_logged_in?(m)) != false && (user = AccountFux0r.first(:user => user)).nil? == false
    
    a = Mechanize.new
    a.get('https://ssl.fux0r.eu/login.php') do |page|
      # Submit login page
      idx_page = page.form_with(:action => "login.php") do |f|
        f.username = user.username
        f.password = user.password
      end.submit
      search_page = a.click(idx_page.link_with(:href => "torrents.php"))
      search_page = a.click(search_page.link_with(:href => "torrents.php?action=advanced"))
      results_page = search_page.form_with(:name => "filter") do |f|
        f.freeleech = 1
      end.submit
      freeleech = []
      print results_page.inspect
      torrents = results_page.search('#content li.torrent_name')[0..4].each { |torrent|
        print torrent.inspect
        freeleech.push(torrent.search('div')[0].children[0, 7].inner_text().strip)
      }
      m.reply "Recent freeleeches: " + freeleech.join(", ")
    end
  end
  
  def link(m, username, password)
    return m.reply("Please sign into Savage first") unless (user = is_logged_in?(m)) != false
    return m.reply("That Fux0r account is already linked") if AccountFux0r.first(:username => username).nil? == false
    AccountFux0r.create(:username => username, :password => password, :user => user)
    m.reply("Credentials have been saved for your Fux0r account")
  end
  
  def unlink(m)
    return m.reply("Please sign into Savage first") unless (user = is_logged_in?(m)) != false
    return m.reply("There is no Fux0r account linked to #{m.user.authname}") if (link = AccountFux0r.first(:user => user)).nil?
    link.destroy
    m.reply("That Fux0r account has been unlinked from #{m.user.authname}")
  end
  
  listen_to :help, method: :help
  def help(m)
    m.reply("!fux0r stats (!fux0r) - Retrieve your statistics from Fux0r")
    m.reply("!fux0r freeleech - Display the last 5 freeleech albums from Fux0r")
    m.reply("!fux0r link username password - Connect your Savage account to a Fux0r account")
    m.reply("!fux0r unlink - Break the connection between your Savage account and Fux0r account")
  end
end