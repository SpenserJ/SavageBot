require 'mechanize'

module SavageBot
  module Plugins
    class UrbanDictionary
      include Cinch::Plugin
      
      match /urban (.+)/
      def execute(m, word)
        a = Mechanize.new
        page = a.get((url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(word)}"))
        return m.reply("#{word} is not defined yet") if page.search('#not_defined_yet').count != 0
        word       = CGI.unescape_html(page.search('td.word')       [0].inner_text).gsub(/\s+/, ' ').strip
        definition = CGI.unescape_html(page.search('div.definition')[0].inner_text).gsub(/\s+/, ' ').strip
        m.reply("#{m.user.nick}: #{word} - #{definition} (#{url})");
      end
    end
  end
end