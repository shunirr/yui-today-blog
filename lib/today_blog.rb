module TodayBlog
  autoload :SameDay,      'today_blog/same_day'
  autoload :RSS  ,        'today_blog/rss'
  autoload :YuikaoriInfo, 'today_blog/yuikaori_info'

  module Model
    autoload :Duplicate, 'today_blog/model/duplicate'
  end
end
