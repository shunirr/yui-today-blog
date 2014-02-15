module TodayBlog
  autoload :SameDay, 'today_blog/same_day'
  autoload :Today,   'today_blog/today'

  module Model
    autoload :Duplicate, 'today_blog/model/duplicate'
  end
end
