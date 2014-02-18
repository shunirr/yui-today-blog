# -*- encoding: utf-8 -*-

require 'nokogiri'
require 'open-uri'
require 'date'
require 'digest/sha1'

module TodayBlog
  class YuikaoriInfo
    def initialize(arg = {})
      @url = arg[:url] || 'http://cnt.kingrecords.co.jp/yuikaori/info/index.html'
    end

    def entries
      load_entries
      @entries
    end

    private
    def load_entries
      doc = nil
      count = 3
      begin
        doc = Nokogiri::HTML.parse open(@url).read
      rescue => e
        count -= 1
        sleep 10
        retry if count > 0
      end

      return unless doc
      
      @entries = []
      doc.xpath('//div[@class="box01"]').each do |entry|
        title = entry.xpath('dl/dt').text
        date = Date.today
        if title.match /^(.*)(\(|（)(\d+\/\d+\/\d+)(）|\))\s*$/
          title = $1
          date = Date.parse $3
        end

        @entries << {
          :title => title,
          :url   => @url,
          :date  => date,
          :identify => Digest::SHA1.hexdigest(title),
        }
      end
    end
  end
end
