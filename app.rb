#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

$: << 'lib'

require 'today_blog'
require 'date'
require 'twitter'
require 'clockwork'
require 'active_record'

include Clockwork

WDAYS = ['日', '月', '火', '水', '木', '金', '土']

def init_db
  url = ENV['HEROKU_POSTGRESQL_PURPLE_URL']
  if url
    ActiveRecord::Base.establish_connection(url)
  else
    ActiveRecord::Base.establish_connection(
      :adapter  => 'sqlite3',
      :database => 'db/sqlite.db'
    )
  end
end

def jst2utc(jst_hour)
  sprintf('%02d:%02d', (jst_hour - 9), 0)
end

def format_date(date)
  "#{date.year}年#{date.month}月#{date.day}日(#{WDAYS[date.wday]})"
end

def post_twitter(entry)
  date = format_date entry[:date]
  message = "#{date}のゆいゆい日記です / #{entry[:title]} #{entry[:url]} #小倉唯"
  puts message
  # $client.update message
end

init_db

$client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['consumer_key']
  config.consumer_secret     = ENV['consumer_secret']
  config.access_token        = ENV['access_token']
  config.access_token_secret = ENV['access_token_secret']
end

every(1.day, 'same_day.job', :at => jst2utc(16)) do
  same = TodayBlog::SameDay.new Date.today
  same.entries.each do |entry|
    post_twitter entry
    sleep 10
  end
end

every(10.minutes, 'today.job') do
  today = TodayBlog::Today.new
  today.entries.each do |entry|
    duplicate = TodayBlog::Model::Duplicate.find_by_url entry[:url]
    unless duplicate
      duplicate = TodayBlog::Model::Duplicate.new
      duplicate.url = entry[:url]
      duplicate.save!

      post_twitter entry
    end
  end
end
