# -*- encoding: utf-8 -*-

require 'rss'
require 'date'

module TodayBlog
  class RSS
    def initialize(arg)
      @url              = arg[:url]
      @valid_url_prefix = arg[:valid_url_prefix]
    end

    def entries
      load_entries
      @entries
    end

    private
    def load_entries
      rss = ::RSS::Parser.parse(@url)
      rss = rss.items.delete_if do |i|
        not i.link.start_with? @valid_url_prefix
      end
      @entries = []
      rss.map do |i|
        @entries << {
          :title    => i.title,
          :url      => i.link,
          :identify => i.link,
          :date     => i.date,
        }
      end
    end
  end
end
