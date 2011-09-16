require 'xmlrpc/client'

class RTorrent
  include Cinch::Plugin
  
  match /(feral )?hdd$/, method: :hdd
  match /(feral )?bandwidth$/, method: :bandwidth
  
  def initialize(bot)
    @rpc = XMLRPC::Client.new("rat.feralhosting.com", "/spenserj/RPC", 80, nil, nil, 'rutorrent', 'FQPKTiafOgX1ZXV7')
    print "\n\n\n\n\n" + @rpc.inspect + "\n\n\n\n\n"
    print @rpc.multicall(
      ['get_up_total', []],
      ['get_down_total', []],
      ['get_upload_rate', []],
      ['get_download_rate', []]).inspect + "\n\n\n\n\n"
    return bot
  end
  
  def hdd(m)
    return unless is_configured?(m.user)
    json = feral_api(m.user.nick, 'server/disk')
    m.reply "#{m.user.nick}: You have used " + (json['kilobytes'].to_f / 1024 / 1024).round(2).to_s + ' GB of HDD space'
  end
  
  def bandwidth(m)
    return unless is_configured?(m.user)
    json = feral_api(m.user.nick, 'server/bandwidth')
    m.reply "#{m.user.nick}: You have uploaded " + (json['upload-external-bytes'].to_f / 1024 / 1024 / 1024).round(2).to_s + ' GB'
  end
  
  listen_to :help, method: :help
  def help(m)
    m.user.send("!feral hdd (!hdd) - Retrieve your HDD usage from FeralHosting\n" +
                "!feral bandwidth (!bandwidth) - Retrieve your bandwidth usage from FeralHosting")
  end
end