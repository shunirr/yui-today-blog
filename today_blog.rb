#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'csv'
require 'date'
require 'twitter'
require 'clockwork'

class TodayBlog 
  def initialize(args = {})
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = args['consumer_key']
      config.consumer_secret     = args['consumer_secret']
      config.access_token        = args['access_token']
      config.access_token_secret = args['access_token_secret']
    end
  end

  def post
    load_today_blogs
    post_today_blogs
  end

  private
  def load_today_blogs
    @entries = []
    today = Date.today
    CSV.foreach("entries.csv") do |row|
      date_string, title, url = row
      year, month, day = date_string.split('-')
      if today.month == month.to_i and today.day == day.to_i
        @entries << {:date => date_string, :url => url, :title => title}
      end
    end
  end

  def post_today_blogs
    @entries.each do |entry|
      @client.update("#{entry[:date]}のゆいゆい日記です #{entry[:title]} #{entry[:url]} #小倉唯")
      sleep 10
    end
  end
end

include Clockwork

handler do |job|
  puts "Running #{job}"
  today_blog = TodayBlog.new({
      'consumer_key'        => ENV['consumer_key'],
      'consumer_secret'     => ENV['consumer_secret'],
      'access_token'        => ENV['access_token'],
      'access_token_secret' => ENV['access_token_secret'],
  })
  today_blog.post
end

every(1.day, 'today_blog.job', :at => '07:00')

