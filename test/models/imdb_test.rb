require 'test_helper'

class ImdbTest < ActiveSupport::TestCase
  test "test scrape work page, tv_show" do
    data = { title: "Veronica Mars", url: "/title/tt0412253/"}
    expected = { title: "Veronica Mars",
      url: "/title/tt0412253/", 
      category: 1,
      rating: "8.4", 
      credits: ["/name/nm0859432"]
    }
    actual = Imdb.scrape_work_page(data)
    assert_equal(expected, actual, "failed scrape work page\nexpected: #{expected}\nactual: #{actual}")
  end

  test "test scrape work page, movie" do
    data = { title: "The Dark Knight", url: "/title/tt0468569/" }
    expected = { title: "The Dark Knight",
      url: "/title/tt0468569/", 
      category: 0,
      rating: "9.0",
      credits: ["/name/nm0634240"]
    }
    actual = Imdb.scrape_work_page(data)
    assert_equal(expected, actual, "failed scrape work page\nexpected: #{expected}\nactual: #{actual}")
  end

  test "test scrape work page, with no rating" do
    data = { title: "Elvis, Trump and WhatsHisName Movie", url: "/title/tt7780980/" }
    expected = { title: "Elvis, Trump and WhatsHisName Movie",
      url: "/title/tt7780980/",
      category: 0,
      rating: "",
      credits: ["/name/nm0347342"]
    }
    actual = Imdb.scrape_work_page(data)
    assert_equal(expected, actual, "failed scrape work page\nexpected: #{expected}\nactual: #{actual}")
  end

  test "test save work" do
    work = { title: "Elvis, Trump and WhatsHisName Movie",
      url: "/title/tt7780980/",
      category: 0,
      rating: "",
      credits: ["/name/nm0347342"]
    }
    Imdb.save_work(work)
    w = Work.find_by(url: "/title/tt7780980/")
    assert_equal(work[:title], w.title)
    assert_equal("#{Work::DOMAIN}#{work[:url]}", w.url)
    assert_equal("movie", w.category)
    assert_equal(nil, w.rating)
    # todo: save crew member and test credits
  end

  test "test scrape work page, multiple credits" do
    data = { title: "Family Guy", url: "/title/tt0182576/" } 
    expected = { title: "Family Guy",
      url: "/title/tt0182576/", 
      category: 1,
      rating: "8.2",
      credits: ["/name/nm0532235","/name/nm0958412"]
    }
    actual = Imdb.scrape_work_page(data)
    assert_equal(expected, actual, "failed scrape work page\nexpected: #{expected}\nactual: #{actual}")
  end

  test "test scrape search page" do
    url = "https://www.imdb.com/search/name?birth_monthday=02-29&count=100"
    actual = Imdb.scrape_search_page(url)
    first_result = {
      name: "Peter Scanavino",
      photo_url: "https://ia.media-imdb.com/images/M/MV5BMTUwNTA5OTk2OV5BMl5BanBnXkFtZTgwODM2OTgyMTE@._V1_UY209_CR65,0,140,209_AL_.jpg", 
      profile_url: "/name/nm1813581",
      work_title: "Deception",
      work_url: "/title/tt0800240/",
      role: "Actor",
      birthdate: "0004-02-29".to_date
    }
    last_result = {
      name: "Stephen Chalmers",
      photo_url: "https://ia.media-imdb.com/images/M/MV5BOTMyMzE5OTcwOV5BMl5BanBnXkFtZTYwNDUwMDY2._V1_UY209_CR15,0,140,209_AL_.jpg",
      profile_url: "/name/nm0150042",
      work_title: "Looking for Trouble",
      work_url: "/title/tt0017079/",
      role: "Writer",
      birthdate: "0004-02-29".to_date
    } 
    assert_equal(first_result, actual.first, "failed\nexpected first result: #{first_result}\nactual: #{actual.first}")
    assert_equal(last_result, actual.last, "failed\nexpected last result: #{last_result}\nactual: #{actual.last}")
    assert_equal(320, actual.size, "failed expected results size: 320, actual #{actual.size}")
  end

  test "test save person" do
    person = { name: "Hugh Jackman",
      photo_url: "https://ia.media-imdb.com/images/M/MV5BNDExMzIzNjk3Nl5BMl5BanBnXkFtZTcwOTE4NDU5OA@@._V1_UX140_CR0,0,140,209_AL_.jpg",
      profile_url: "/name/nm0413168",
      work_title: "Les Misérables",
      work_url: "/title/tt1707386/",
      role: "Actor",
      birthdate: "12-10-0004".to_date
    }
   Imdb.save_person(person)
   p = Person.find_by(profile_url: "/name/nm0413168")
    assert_equal(person[:name], p.name)
    assert_equal(person[:photo_url], p.photo_url)
    assert_equal("#{Person::DOMAIN}#{person[:profile_url]}", p.profile_url)
    assert_equal(person[:birthdate], p.birthdate)
    # todo: save crew member and test roles
  end

  test "test create associations" do
    person = { name: "Hugh Jackman",
      photo_url: "https://ia.media-imdb.com/images/M/MV5BNDExMzIzNjk3Nl5BMl5BanBnXkFtZTcwOTE4NDU5OA@@._V1_UX140_CR0,0,140,209_AL_.jpg",
      profile_url: "/name/nm0413168",
      work_title: "Les Misérables",
      work_url: "/title/tt1707386/",
      role: "Actor",
      birthdate: "12-10-0004".to_date
    }
    works = {
      '/title/tt1707386/': {title: "Les Misérables",
        url: "/title/tt1707386/",
        rating: "7.6",
        credits: ["/name/nm0413168"]
        }
    }
    person_obj = Person.create(name: person[:name], profile_url: person[:profile_url], photo_url: person[:photo_url])
    work_obj = Work.create(title: "Les Misérables", url: "/title/tt1707386/")
    people = {}
    people['10-12'] = [person] 
    Imdb.create_associations(people,works)
    crew_member = CrewMember.find_by(person: person_obj, work: work_obj)
    assert_not_nil(crew_member, "crew_member is nil")
    assert_not_nil(crew_member.roles, "roles not nil")
    actor = Role.find_by(name: "Actor")
    director = Role.find_by(name: "Director")
    assert_includes(crew_member.roles, actor, "actor not included in roles, actual: #{crew_member.roles}")
    assert_includes(crew_member.roles, director, "director not included in roles, actual: #{crew_member.roles}")
  end
end
