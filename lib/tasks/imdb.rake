namespace :imdb do
  task :scrape => :environment do
    Imdb.run_scrape_task
  end
end
