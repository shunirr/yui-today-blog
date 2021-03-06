# -*- encoding: utf-8 -*-

require 'csv'
require 'date'

module TodayBlog
  class SameDay
    def initialize(args = {})
      @date = args[:date] || Date.today
      @csv  = args[:csv]
    end

    def entries
      load_today_blogs
      @entries
    end
  
    private
    def load_today_blogs
      @entries = []
      CSV.foreach(@csv) do |row|
        date_string, title, url = row
        year, month, day = date_string.split('-')
        if @date.month == month.to_i and @date.day == day.to_i
          @entries << {
            :date => Date.parse(date_string),
            :url => url,
            :title => title
          }
        end
      end
    end
  end
end
