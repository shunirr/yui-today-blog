#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'csv'
require 'date'
require 'twitter'
require 'open-uri'
require 'nokogiri'
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
      date_string, url = row
      year, month, day = date_string.split('-')
      @entries << url if today.month == month.to_i and today.day == day.to_i
    end
  end

  def post_today_blogs
    @entries.each do |url|
      doc = Nokogiri::HTML.parse(open(url).read)
      title = doc.xpath('//h1/a[@class="skinArticleTitle"]').first.text.gsub("\n", '')
      date = doc.xpath('//span[@class="articleTime"]').text
      client.update("#{date}のゆいゆい日記です #{title} #{url} #小倉唯")
      sleep 60
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

every(1.day, 'today_blog.job', :at => '08:10')

