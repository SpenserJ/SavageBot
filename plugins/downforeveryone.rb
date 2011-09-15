require "mechanize"
class DownForEveryone
  include Cinch::Plugin

  def initialize(*args)
    super

    @agent = Mechanize.new
    @agent.user_agent_alias = "Linux Mozilla"
  end

  match /dfeojm (.+)/
  match /downforeveryone (.+)/
  
  def execute(m, url)
    url = url.gsub(/^https?:\/\//, '')
    page = @agent.get("http://downforeveryoneorjustme.com/#{url}")
    if page.title.split(" -> ").first =~ / Up$/
      m.reply "It's just you. #{url} is up."
    else
      m.reply "It's not just you! #{url} looks down from here."
    end
  end
  
  listen_to :help, method: :help
  def help(m)
    m.reply("!dfeojm domain (!downforeveryone domain) - Check if a website is online or offline")
  end
end