#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

$: << 'lib'

require 'today_blog'
require 'date'
require 'twitter'
require 'clockwork'

include Clockwork

WDAYS = ['日', '月', '火', '水', '木', '金', '土']

def jst2utc(jst_hour)
  sprintf('%02d:%02d', (jst_hour - 9), 0)
end

def format_date(date)
  "#{date.year}年#{date.month}月#{date.day}日(#{WDAYS[date.wday]})"
end

$client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['consumer_key']
  config.consumer_secret     = ENV['consumer_secret']
  config.access_token        = ENV['access_token']
  config.access_token_secret = ENV['access_token_secret']
end

every(1.day, 'today_blog.job', :at => jst2utc(16)) do
  same = TodayBlog::SameDay.new Date.today
  same.entries.each do |entry|
    date = format_date entry[:date]
    message = "#{date}のゆいゆい日記です / #{entry[:title]} #{entry[:url]} #小倉唯"
    puts message
    $client.update message
    sleep 10
  end
end

