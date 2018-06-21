namespace :db do
  namespace :production do
    desc "Migrate both databases in production"
    task :migrate => :environment do
      if Rails.env.production?

        [:write_production, :read_production].each do |connection|
          ActiveRecord::Base.clear_all_connections!
          ActiveRecord::Base.establish_connection(connection)
          Rake::Task['db:migrate'].invoke
        end
      end
    end
  end
end
