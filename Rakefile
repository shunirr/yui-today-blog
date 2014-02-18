require 'active_record'

task :default => :migrate

namespace :db do
  desc 'Migrate database'
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate('db/migrate')
  end

  task :environment do
    url = ENV['HEROKU_POSTGRESQL_PURPLE_URL']
    if url
      ActiveRecord::Base.establish_connection(url)
    else
      ActiveRecord::Base.establish_connection(
        :adapter  => 'sqlite3',
        :database => 'db/sqlite.db'
      )
    end
    ActiveRecord::Base.logger = Logger.new(File.open('db/database.log', 'a'))
  end
end
