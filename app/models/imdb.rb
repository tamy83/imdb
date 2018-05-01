class Imdb
  require 'open-uri'
  require 'concurrent'

  DOMAIN = 'https://www.imdb.com'
  # 50 || 100
  RESULTS_PER_PAGE = 100

  PEOPLE_THREADS_COUNT = 20
  WORK_THREADS_COUNT = 30
  DB_THREADS_COUNT = 1
  
  # amount of work obj to import at once
  WORK_BATCH_SIZE = 1000

  @@errors = []
  def self.run_scrape_task
    @@errors = []
    @@people_pool = Concurrent::FixedThreadPool.new(PEOPLE_THREADS_COUNT)
    @@work_pool = Concurrent::FixedThreadPool.new(WORK_THREADS_COUNT)
    @@db_pool = Concurrent::FixedThreadPool.new(DB_THREADS_COUNT)
    Rails.logger.debug "BEGIN IMDB SCRAPE TASK"
    monthdays = {
#      '31': [ '01', '03', '05', '07', '08', '10', '12' ],
#      '30': [ '04', '06', '09', '11' ],
      '01': [ '02' ]
    }
    @@people = {}
    @@works = {}
    monthdays.each do |key, array|
      key.to_s.to_i.times { |i|
        dd = format('%02d', i+1)
        array.each { |mm|
          @@people_pool.post do
            begin
              url = "#{DOMAIN}/search/name?birth_monthday=#{mm}-#{dd}&count=#{RESULTS_PER_PAGE}"
              @@people["#{mm}-#{dd}"] = self.scrape_search_page(url)
              Rails.logger.debug("ytam thread #{Thread.current.object_id} finished #{mm} #{dd}")
              @@people["#{mm}-#{dd}"].each { |hash|
                #self.scrape_work({title: hash[:work_title], url: hash[:work_url]})
                self.post_to_work_pool({title: hash[:work_title], url: hash[:work_url]})
              }
              self.queue_mass_import_of_people(@@people["#{mm}-#{dd}"])
            rescue => e
              self.log("ytam thread #{Thread.current.object_id} error #{e.message}\n\n#{e.backtrace.join("\n")}")
            end
          end
        }
      }
    end
    @@people_pool.shutdown
    @@people_pool.wait_for_termination
    @@work_pool.shutdown
    @@work_pool.wait_for_termination
    groups = @@works.size / WORK_BATCH_SIZE
    remainder = @@works.size % WORK_BATCH_SIZE
    groups.times { |i|
      self.queue_mass_import_of_works(@@works.values[WORK_BATCH_SIZE*i,WORK_BATCH_SIZE])
    }
    self.queue_mass_import_of_works(@@works.values[WORK_BATCH_SIZE*groups,remainder+1])
    @@db_pool.shutdown
    @@db_pool.wait_for_termination
    population = 0
    @@people.each { |key, array|
      Rails.logger.debug "date: #{key.to_s} size: #{array.size}"
      population += array.size
    }
    Rails.logger.debug "END IMDB SCRAPE TASK
      people: #{population},
      works: #{@@works.keys.size},
      people_imported: #{Person.all.count} missed: #{population-Person.all.count},
      works_imported: #{Work.all.count} missed: #{@@works.keys.size-Work.all.count}
      "
    self.dump_errors_to_logfile 
  end

  private 

  def self.log(msg)
    Rails.logger.error msg
    @@errors.push(msg)
  end

  def self.dump_errors_to_logfile
    @@errors.each { |msg|
      Rails.logger.error msg
    }
  end

  def self.queue_mass_import_of_people(people)
    @@db_pool.post do
      columns = [:name, :photo_url, :profile_url, :birthdate]
      Person.import(columns, people)
    end
  end

  def self.queue_mass_import_of_works(works)
    @@db_pool.post do
      begin
        columns = [:title, :url, :category, :rating]
        Work.import(columns, works)
      rescue => e
        self.log("ERROR: failed work import size: #{works.size}, msg: #{e.message}, #{e.stacktrace}")
      end
    end
  end

  def self.post_to_work_pool(data)
    @@work_pool.post do
      work = self.scrape_work_page(data)
      @@works[data[:url]] = work if work
    end if @@works[:url].nil?
  end

  def self.scrape_work(data)
    if @@works[:url].nil?
      work = self.scrape_work_page(data)
      @@works[data[:url]] = work if work
    end
  end

  def self.scrape_search_page(url)
    Rails.logger.debug "ytam thread: #{Thread.current.object_id} on page: #{url}"
    begin
      doc = Nokogiri::HTML(open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
    rescue => e
      self.log("ERROR: #{e.message} for #{url}")
      return
    end
    mm, dd = url.match(/birth_monthday=(\d*)-(\d*)\&/).captures
    header_text = doc.xpath('//*[@id="main"]/div/h1').text
    result_mm, result_dd = header_text.match(/Birth Month Day of (.*)-(.*)/).captures
    results = nil
    if mm == result_mm && dd == result_dd
      results = []
      doc.xpath('//*[@id="main"]/div/div[3]').children.each do |node|
        if node.is_a?(Nokogiri::XML::Element)
          data = self.process_person(node)
          data[:birthdate] = "#{dd}-#{mm}-0004".to_date
          results.push(data)
        end
      end
      if !url.include? 'start'
        total_results_str = doc.xpath('//*[@id="main"]/div/div[1]/span[1]').text
        arr = total_results_str.match(/of (.*) names/).captures
        total_str = arr[0]
        total = total_str.sub(',','').to_i
        
        Rails.logger.debug "got #{total} results"
        num_of_pages = total / RESULTS_PER_PAGE
        array = []
        num_of_pages.times { |i|
          array.push RESULTS_PER_PAGE * (i+1) + 1
        }
        array.each { |position|
          res = self.scrape_search_page(url+"&start=#{position}")
          results.concat(res) if res
        }
      end
    else
      self.log("ERROR: did not receive correct search result page for #{mm}-#{dd} #{url}")
    end
    results
  end

  def self.save_person(data)
    Person.create(name: data[:name], profile_url: data[:profile_url], photo_url: data[:photo_url], birthdate: data[:birthdate])
  end
 
=begin
  def self.create_crew_members()
    if data[:work_title] && data[:work_url]
      work = Work.find_or_create_by(title: data[:work_title], url: "#{data[:work_url]}")
      unless person.works.include? work
        crew_member = CrewMember.find_or_create_by(person: person, work: work)
        if data[:role]
          role = Role.find_or_create_by(name: data[:role])
          crew_member.roles.push(role)
          crew_member.save
        end
      end
    end
    person.save
  end
=end
 
  def self.process_person(node)
    name = node.xpath('./div/a/img').first.attributes['alt'].value
    photo_url = node.xpath('./div/a/img').first.attributes['src'].value
    profile_url = node.xpath('./div/a').first.attributes['href'].value
    work_section = node.xpath('./div/p/a').first
    if work_section
      work_title = work_section.text.strip!
      work_url = work_section.attributes['href'].value.split("?").first
      role = node.xpath('./div/p').text.split('|').first.strip! if node.xpath('./div/p').text.include? '|'
    end
    return {name: name,
      photo_url: photo_url,
      profile_url: profile_url,
      work_title: work_title,
      work_url: work_url,
      role: role
    }
  end

  def self.scrape_work_page(data)
    Rails.logger.debug "ytam on work page: #{data[:url]}"
    return if data[:url].nil?
    begin
      doc = Nokogiri::HTML(open("#{DOMAIN}#{data[:url]}", :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
    title = doc.xpath('//*[@id="title-overview-widget"]/div[2]/div[2]/div/div[2]/div[2]/h1').text
    title = doc.xpath('//*[@id="title-overview-widget"]/div[2]/div[2]/div/div/div[2]/h1').text if title.blank?
    title = title.gsub("\u00A0","").split("(").first
    title.strip!
    self.log("WARN: received page for #{data[:url]}, title: #{title}, expected_title: #{data[:title]}") unless title == data[:title]
    # todo: .to_d was removed from rating, not necessary to convert
    rating = doc.xpath('//*[@id="title-overview-widget"]/div[2]/div[2]/div/div[1]/div[1]/div[1]/strong/span').children.text
    # different paths whether or not a trailer exists so search by class name
    #credits_node = doc.xpath('//*[@id="title-overview-widget"]/div[3]/div[1]/div[2]/span')
    #credits_node = doc.xpath('//*[@id="title-overview-widget"]/div[3]/div[2]/div/div[2]/span')
    all_credits_node = doc.xpath("//div[contains(@class, 'credit_summary_item')]") 
    dir_creator_node = all_credits_node.first.xpath('./span')
    category = (doc.xpath('//*[@id="main_bottom"]/div[1]/h2').text=='Episodes') ? 1 : 0
    credits = [] 
    dir_creator_node.each { |credit|
      if credit.attributes['itemprop'] 
        #role = credit.attributes['itemprop'].value.capitalize!
        #category = (role == 'Creator') ? 1 : 0 
        profile_url = credit.xpath('./a').first.attributes['href'].value.split('/?').first
        credits.push("#{profile_url}")
      end
    }
    return {title: data[:title], url:data[:url], category: category, rating: rating, credits: credits}
    rescue => e
      self.log("ERROR: #{e.message} for #{data[:url]}, title: #{data[:title]}, stacktrace: #{e.stacktrace}")
    end
  end

  def self.save_work(data)
    Work.create(title: data[:title], url: data[:url], rating: data[:rating], category: data[:category])
=begin
    role = data[:category] ? 'Creator' : 'Director'
    credits.each { |credit|
      p = Person.find_or_create_by(profile_url: credit)
      crew_member = CrewMember.find_or_create_by(person: p, work: work)
      crew_member.roles.push(Role.find_or_create_by(name: role))
      crew_member.save
    }
=end
  end
end
