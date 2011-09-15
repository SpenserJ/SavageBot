# https://raw.github.com/crshd/Bwanana/master/plugins/scores.rb

class Score # {{{
  include DataMapper::Resource

  property(:id,         Serial)
  property(:name,       String, :unique => true)
  property(:score,      Integer, :default => 0)
  property(:created_at, EpochTime)
end # }}}

module Plugins
  class Scores # {{{
    include Cinch::Plugin
    react_on :channel

    match /(\+\+|--)(.+)/, method: :change
    def change(m, op, key)
      begin
        lookup = key.downcase.strip
        score  = Score.first(:name.like => lookup)

        # New score
        if(score.nil?)
          score = Score.new(
            :name       => lookup,
            :score      => 0,
            :created_at => Time.now
          )
        end

        # In-/decrease score
        if(m.user.nick.downcase.strip == lookup)
          score.score = score.score - 1
        else
          score.score = case op
            when "++" then score.score + 1
            when "--" then score.score - 1
          end
        end

        if(score.score == 0)
          score.destroy!

          m.reply "Zeroed out", true
        else
          score.save

          m.reply "Score of %s is now %d" % [ key, score.score ], true
        end
      rescue => error
        m.reply "Oops something went wrong"
        raise
      end
    end

    match /score (.+)/, method: :score
    def score(m, key)
      begin
        lookup = key.downcase.strip
        score  = Score.first(:name.like => lookup)

        unless(score.nil?)
          m.reply "Score of %s is %d" % [ lookup, score.score ], true
        end
      rescue => error
        m.reply "Oops something went wrong", true
        raise
      end
    end

    match /(best|worst)$/, method: :top_score
    def top_score(m, op)
      begin
        # Get scores
        case op
        when "best"
          scores = Score.all(:order => [ :score.desc ], :limit => 10)
        when "worst"
          scores = Score.all(:score.lt => 0, :order => [ :score.asc ], :limit => 10)
        end

        unless(scores.nil?)
          matches = []

          scores.each do |s|
            matches << "%s[%d]" % [ s.name, s.score ]
          end

          unless(matches.empty?)
            m.reply matches.join(", "), true
          end
        end
      rescue => error
        m.reply "Oops something went wrong", true
        raise
      end
    end
  end # }}}
end