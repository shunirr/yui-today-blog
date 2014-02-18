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

def post_twitter(blog_title, entry)
  date = format_date entry[:date]
  message = "#{date}の#{blog_title}です / #{entry[:title]} #{entry[:url]} #小倉唯 #石原夏織 #ゆいかおり"
  puts message
  $client.update message
end

init_db

$client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['consumer_key']
  config.consumer_secret     = ENV['consumer_secret']
  config.access_token        = ENV['access_token']
  config.access_token_secret = ENV['access_token_secret']
end

every(1.day, 'same_day.job', :at => jst2utc(16)) do
  same = TodayBlog::SameDay.new :csv => 'ogura-yui.csv'
  same.entries.each do |entry|
    post_twitter 'ゆいゆい日記', entry
    sleep 10
  end
end

every(10.minutes, 'ogurayui-0815.job') do
  today = TodayBlog::RSS.new(
    :url => 'http://feedblog.ameba.jp/rss/ameblo/ogurayui-0815/rss20.xml',
    :valid_url_prefix => 'http://ameblo.jp/ogurayui-0815',
  )
  today.entries.each do |entry|
    duplicate = TodayBlog::Model::Duplicate.find_by_identify entry[:identify]
    unless duplicate
      duplicate = TodayBlog::Model::Duplicate.new
      duplicate.identify = entry[:identify]
      duplicate.save!

      post_twitter 'ゆいゆいティータイム', entry
    end
  end
end

every(10.minutes, 'ishiharakaori-0806.job') do
  today = TodayBlog::RSS.new(
    :url => 'http://feedblog.ameba.jp/rss/ameblo/ishiharakaori-0806/rss20.xml',
    :valid_url_prefix => 'http://ameblo.jp/ishiharakaori-0806',
  )
  today.entries.each do |entry|
    duplicate = TodayBlog::Model::Duplicate.find_by_identify entry[:identify]
    unless duplicate
      duplicate = TodayBlog::Model::Duplicate.new
      duplicate.identify = entry[:identify]
      duplicate.save!

      post_twitter 'Mahalo.', entry
    end
  end
end

every(1.hour, 'yuikaori_info.job') do
  info = TodayBlog::YuikaoriInfo.new
  info.entries.each do |entry|
    duplicate = TodayBlog::Model::Duplicate.find_by_identify entry[:identify]
    unless duplicate
      duplicate = TodayBlog::Model::Duplicate.new
      duplicate.identify = entry[:identify]
      duplicate.save!

      post_twitter 'ゆいかおりINFORMATION', entry
    end
  end
end
