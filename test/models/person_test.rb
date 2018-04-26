require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "valid person" do
    person = Person.new(name: "Gemma Arterton", photo_url: "https://images-na.ssl-images-amazon.com/images/M/MV5BOTAwNTMwMzE5OF5BMl5BanBnXkFtZTgwMjYwNzI2MjE@._V1_UX140_CR0,0,140,209_AL_.jpg", profile_url: "http://www.imdb.com/name/nm2605345t", birthdate: Date.today) 
    assert person.valid?
  end

  test "invalid without name" do
    person = Person.new(photo_url: "https://images-na.ssl-images-amazon.com/images/M/MV5BOTAwNTMwMzE5OF5BMl5BanBnXkFtZTgwMjYwNzI2MjE@._V1_UX140_CR0,0,140,209_AL_.jpg", profile_url: "http://www.imdb.com/name/nm2605345t", birthdate: Date.today)
    refute person.valid?
    assert_not_nil person.errors[:name]
  end

  test "invalid photo_url" do
    person = Person.new(name: "Gemma Arterton", photo_url: "images.jpg", profile_url: "http://www.imdb.com/name/nm2605345t", birthdate: Date.today)
    refute person.valid?
    assert_not_nil person.errors[:photo_url]
  end

  test "invalid profile_url" do
    person = Person.new(name: "Gemma Arterton", photo_url: "https://images-na.ssl-images-amazon.com/images/M/MV5BOTAwNTMwMzE5OF5BMl5BanBnXkFtZTgwMjYwNzI2MjE@._V1_UX140_CR0,0,140,209_AL_.jpg", profile_url: "www.imdb.com/nm2605345t", birthdate: Date.today)
    refute person.valid?
    assert_not_nil person.errors[:profile_url]
  end
end
