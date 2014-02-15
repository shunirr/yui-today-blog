
require 'rss'
require 'date'

module TodayBlog
  class Today
    def initialize(arg = {})
      @url = arg[:url] || 'http://feedblog.ameba.jp/rss/ameblo/ogurayui-0815/rss20.xml'
      @valid_url_prefix = arg[:valid_url_prefix] || 'http://ameblo.jp/ogurayui-0815'
    end

    def entries
      load_entries
      @entries
    end

    private
    def load_entries
      rss = RSS::Parser.parse(@url)
      rss = rss.items.delete_if do |i|
        not i.link.start_with? @valid_url_prefix
      end
      @entries = []
      rss.map do |i|
        @entries << {
          :title => i.title,
          :url   => i.link,
          :date  => i.date,
        }
      end
    end
  end
end
