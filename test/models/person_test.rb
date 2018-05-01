require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "valid person" do
    person = Person.new(name: "Gemma Arterton", photo_url: "https://images-na.ssl-images-amazon.com/images/M/MV5BOTAwNTMwMzE5OF5BMl5BanBnXkFtZTgwMjYwNzI2MjE@._V1_UX140_CR0,0,140,209_AL_.jpg", profile_url: "http://www.imdb.com/name/nm2605345t", birthdate: Date.today) 
    assert person.valid?
  end

  test "invalid photo_url" do
    person = Person.new(name: "Gemma Arterton", photo_url: "images.jpg", profile_url: "http://www.imdb.com/name/nm2605345t", birthdate: Date.today)
    refute person.valid?
    refute_empty person.errors[:photo_url]
  end

  test "valid work_rankings validation with valid string" do
    work1 = Work.create(title: "Prince of Persia: The Sands of Time", url: "/title/tt0473075/", rating: 6.6, category: Work.categories[:movie])
    work2 = Work.create(title: "The Sands of Time", url: "/title/tt04123075/", rating: 1.6, category: Work.categories[:movie])
    person = Person.new(name: "Gemma Arterton", photo_url: "https://images-na.ssl-images-amazon.com/images/M/MV5BOTAwNTMwMzE5OF5BMl5BanBnXkFtZTgwMjYwNzI2MjE@._V1_UX140_CR0,0,140,209_AL_.jpg", profile_url: "/name/nm32235345t", birthdate: Date.today, work_rankings: "#{work1.id},#{work2.id}")
    assert_not_nil work1
    assert_not_nil work2
    assert person.valid?
  end

  test "valid work_rankings validation with invalid string" do
    person = Person.new(name: "Gemma Arterton", photo_url: "images.jpg", profile_url: "http://www.imdb.com/name/nm2605345t", birthdate: Date.today, work_rankings: "11,42")
    refute person.valid?
  end

  test "test set new most known work" do
    work1 = Work.create(title: "Prince of Persia: The Sands of Time", url: "/title/tt0473075/", rating: 6.6, category: Work.categories[:movie])
    work2 = Work.create(title: "The Sands of Time", url: "/title/tt04123075/", rating: 1.6, category: Work.categories[:movie])
    person = Person.create(name: "Gemma Arterton", photo_url: "https://images-na.ssl-images-amazon.com/images/M/MV5BOTAwNTMwMzE5OF5BMl5BanBnXkFtZTgwMjYwNzI2MjE@._V1_UX140_CR0,0,140,209_AL_.jpg", profile_url: "/name/nm32235345t", birthdate: Date.today, work_rankings: "#{work1.id},#{work2.id}")
    assert_not_nil work1
    assert_not_nil work2
    assert_not_nil person
    assert_equal("#{work1.id},#{work2.id}", person.work_rankings)
    person.set_most_known_work(work2)
    person.save
    assert_equal("#{work2.id},#{work1.id}", person.work_rankings, "failed setting new most known work")
  end

end
