class Imdb
  require 'open-uri'

  DOMAIN = 'https://www.imdb.com'
  # 50 || 100
  RESULTS_PER_PAGE = 100
  
  @@errors = []
  def self.run_scrape_task
    @@errors = []
    Rails.logger.debug "BEGIN IMDB SCRAPE TASK"
    monthdays = {
      '31': [ '01', '03', '05', '07', '08', '10', '12' ],
      '30': [ '04', '06', '09', '11' ],
      '29': [ '02' ]
    }
    monthdays.each do |key, array|
      key.to_s.to_i.times { |i|
        dd = format('%02d', i+1)
        array.each { |mm|
          url = "#{DOMAIN}/search/name?birth_monthday=#{mm}-#{dd}&count=#{RESULTS_PER_PAGE}"
          self.scrape_search_page(url)
        }
      }
    end
    works = Work.where(rating: nil)
    works.each { |work|
      begin
        self.scrape_work_page(work.url)
      rescue => e
        self.log("ytam ERROR: failed on #{work.url}\n#{e.message}\n\n#{e.backtrace.join("\n")}")
      end
    }
    Rails.logger.debug "END IMDB SCRAPE TASK"
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

  def self.scrape_search_page(url)
    Rails.logger.debug "ytam on page: #{url}"
    doc = Nokogiri::HTML(open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))

    mm, dd = url.match(/birth_monthday=(\d*)-(\d*)\&/).captures
    header_text = doc.xpath('//*[@id="main"]/div/h1').text
    result_mm, result_dd = header_text.match(/Birth Month Day of (.*)-(.*)/).captures
    if mm == result_mm && dd == result_dd
      if !url.include? 'start'
        total_results_str = doc.xpath('//*[@id="main"]/div/div[1]/span[1]').text
        arr = total_results_str.match(/of (.*) names/).captures
        total_str = arr[0]
        total = total_str.sub!(',','').to_i
        
        Rails.logger.debug "got #{total} results"
        num_of_pages = total / RESULTS_PER_PAGE
        array = []
        num_of_pages.times { |i|
          array.push RESULTS_PER_PAGE * (i+1) + 1
        }
        array.each { |position|
          self.scrape_search_page(url+"&start=#{position}")
        }
      end
      Role.transaction do
        CrewMember.transaction do
          Work.transaction do
            Person.transaction do
              doc.xpath('//*[@id="main"]/div/div[3]').children.each do |node|
                if node.is_a?(Nokogiri::XML::Element)
                  begin
                    data = self.process_person(node)
                    person = Person.find_or_initialize_by(profile_url:"#{DOMAIN}#{data[:profile_url]}")
                    person.name = data[:name]
                    person.photo_url = data[:photo_url]
                    person.birthdate = "#{dd}-#{mm}-0000".to_date
                    if data[:work_title] && data[:work_url]
                      work = Work.find_or_create_by(title: data[:work_title], url: "#{DOMAIN}#{data[:work_url]}")
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
                  rescue => e
                    self.log("ERROR: failed on #{node}\n#{data}\n#{e.message}\n\n#{e.backtrace.join("\n")}")
                  end
                end
              end
            end
          end
        end
      end
    else
      self.log("ERROR: did not receive correct search result page for #{mm}-#{dd} #{url}")
    end
  end

  def self.process_person(node)
    name = node.xpath('./div/a/img').first.attributes['alt'].value
    photo_url = node.xpath('./div/a/img').first.attributes['src'].value
    profile_url = node.xpath('./div/a').first.attributes['href'].value
    work_section = node.xpath('./div/p/a').first
    if work_section
      work_title = work_section.text.strip!
      work_url = work_section.attributes['href'].value
      role = node.xpath('./div/p').text.split('|').first.strip! if node.xpath('./div/p').text.include? '|'
    end
    return {name: name, photo_url: photo_url, profile_url: profile_url, work_title: work_title, work_url: work_url, role: role}
  end

  def self.scrape_work_page(url)
    Rails.logger.debug "ytam on page: #{url}"
    doc = Nokogiri::HTML(open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
    
    title = doc.xpath('//*[@id="title-overview-widget"]/div[2]/div[2]/div/div[2]/div[2]/h1').text
    title = doc.xpath('//*[@id="title-overview-widget"]/div[2]/div[2]/div/div/div[2]/h1').text if title.blank?
    title = title.gsub("\u00A0","").split("(").first
    title.strip!
    work = Work.find_by(url: url)
    unless title == work.title
      self.log("ERROR: did not receive correct work page for #{url} #{title} #{work.title}")
      return
    end
    rating = doc.xpath('//*[@id="title-overview-widget"]/div[2]/div[2]/div/div[1]/div[1]/div[1]/strong/span').children.text.to_d
    credits = doc.xpath('//*[@id="title-overview-widget"]/div[3]/div[1]/div[2]/span')
    category = nil
    credits.each { |credit|
      role = credit.attributes['itemprop'].value.capitalize!
      category = (role == 'Creator') ? 1 : 0 
      profile_url = credit.xpath('./a').first.attributes['href'].value.split('/?').first
      p = Person.find_or_initialize_by(profile_url: '#{DOMAIN}#{profile_url}')
      unless p.name
        p.name = credit.xpath('./a').text
        p.save
      end 
      crew_member = CrewMember.find_or_create_by(person: p, work: work)
      crew_member.roles.push(Role.find_or_create_by(name: role))
      crew_member.save 
    }
    category ? work.tv_show! : work.movie!
  end
end
