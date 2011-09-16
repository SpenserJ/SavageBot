require 'mechanize'

module SavageBot
  module Plugins
    class XKCD
      include Cinch::Plugin
      
      listen_to :channel
      
      def initialize(bot)
        super
        @a = Mechanize.new
      end
      
      def listen(m)
        urls = URI.extract(m.message, "http")
        urls.each { |url|
          if url.match(/xkcd.com/)
            m.reply("XKCD: #{url} - " + @a.get(url).search('#middleContent img')[0].attr('title'))
          end
        }
      end
    end
  end
end