def feral_api(username, request)
  user = USERS[username.downcase][0]
  uri = URI.parse("https://www.feralhosting.com/api/json/0.3/#{user}/#{request}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth FERALHOSTING[0], FERALHOSTING[1]
  response = http.request(req)
  JSON.parse(response.body)['response']['0']
end

class FeralHosting
  include Cinch::Plugin
  
  match /(feral )?hdd$/, method: :hdd
  match /(feral )?bandwidth$/, method: :bandwidth
  
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
    m.reply("!feral hdd (!hdd) - Retrieve your HDD usage from FeralHosting")
    m.reply("!feral bandwidth (!bandwidth) - Retrieve your bandwidth usage from FeralHosting")
  end
end