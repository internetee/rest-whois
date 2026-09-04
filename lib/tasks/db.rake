namespace :db do
  namespace :production do
    desc 'Migrate both databases in production'
    task migrate: :environment do
      if Rails.env.production?

        %i[write_production production].each do |connection|
          # ActiveRecord::Base delegated this to the connection handler until 6.1; the
          # delegation is gone since 7.1, the handler method itself is not.
          ActiveRecord::Base.connection_handler.clear_all_connections!
          ActiveRecord::Base.establish_connection(connection)
          Rake::Task['db:migrate'].invoke
        end
      end
    end
  end
end
