namespace :imdb do
  task :scrape => :environment do
    puts "starting scrape task"
    time = Benchmark.measure {
      Imdb.run_scrape_task
    }
    puts "elasped time #{time}"
  end
end
