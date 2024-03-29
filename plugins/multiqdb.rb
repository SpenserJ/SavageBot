# https://raw.github.com/mseymour/azurebot/master/lib/plugins/multiqdb.rb
# -*- coding: UTF-8 -*-

require './plugins/qdb/bash.rb'
require './plugins/qdb/qdbus.rb'
require './plugins/qdb/shakesoda.rb'

module Plugins
	class MultiQDB
		include Cinch::Plugin
		
=begin
		set(
		plugin_name: "QDB",	
		help: "Pulls a quote from a QDB.\n`Usage: !qdb <selector> <ID|latest>`; `!qdb` for selector list.")
=end

		match /qdb\s?(\w+)?\s?(.+)?/
		
		@@selectors = {
			:bash => QDB::Bash,
			:us => QDB::Qdbus,
			:ss => QDB::Shakesoda,
		};
		
		#def generate_url( selector = nil, id = nil )
		def generate_quote( qdb_access, tail = false )
			#return nil if (selector.nil? || @@selectors[selector.to_sym].nil?);
			#return get_base_url(@@selectors[selector.to_sym]) if (is.nil? || tags.empty?);
			begin
				output = []
				output << "#{qdb_access[:fullname]} quote ##{qdb_access[:id]} (#{qdb_access[:meta]}):" unless tail
				output <<  (!tail ? qdb_access[:quote].map {|e| "- #{e}" } : qdb_access[:quotetail].map {|e| "- #{e}" })

				footer = [] 
				footer << (qdb_access[:quote].size < qdb_access[:fullquote].size && !tail ? "#{qdb_access[:fullquote].size - qdb_access[:lines]} lines omitted." : nil)
				footer << "View"
				footer << (qdb_access[:quote].size < qdb_access[:fullquote].size && !tail ? "more from" : nil)
				footer << "this quote at #{qdb_access[:url]}"
				output << footer.reject(&:nil?).join(" ")
					
				output.reject(&:nil?).join("\n");
			rescue
				"Error: #{$!}"
			end
		end
		
		def generate_selector_list
			selectors = [];
			@@selectors.each {|key, value| selectors << key.to_s; }
			selectors[0..-2].join(", ") + ", and " + selectors[-1]
		end
			
		def execute (m, selector = nil, id = nil)
			if (selector.nil? || @@selectors[selector.to_sym].nil?)
			 	m.reply "You have #{!id ? 'not listed a selector' : 'used an invalid selector'}. Valid selectors: %<selectors>s." % {:selectors => generate_selector_list()}
			 else
				qdb_access = @@selectors[selector.to_sym].new(:id => id, :lines => 5).to_hsh;
				
				public_quote = generate_quote(qdb_access)
				m.reply(public_quote);
				
				if qdb_access[:fullquote].size > qdb_access[:quote].size
					sleep 2
					private_quote = generate_quote(qdb_access, true)
					m.user.notice("The rest of the quote:\n" + private_quote);
				end
			end
		end

	end

end