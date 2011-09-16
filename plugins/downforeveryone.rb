require "mechanize"
module SavageBot
  module Plugins
    class DownForEveryone
      include Cinch::Plugin
      
      def initialize(*args)
        super
        
        @agent = Mechanize.new
      end
      
      match /dfeojm (.+)/
      match /downforeveryone (.+)/
      
      def execute(m, url)
        url = url.gsub(/^https?:\/\//, '')
        page = @agent.get("http://downforeveryoneorjustme.com/#{url}")
        m.reply(m.user.nick + ': ' + page.search('#container')[0].children[0, 3].inner_text.strip)
      end
      
      listen_to :help, method: :help
      def help(m)
        m.reply("!dfeojm domain (!downforeveryone domain) - Check if a website is online or offline")
      end
    end
  end
end