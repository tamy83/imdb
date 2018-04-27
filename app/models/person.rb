class Person < ActiveRecord::Base

  has_many :crew_members, dependent: :destroy
  has_many :works, through: :crew_members
  has_many :roles, through: :crew_members

  validates :name, presence: true
  validates :photo_url, format: URI::regexp(%w(http https)), allow_nil: true
  validates :profile_url, format: URI::regexp(%w(http https)), allow_nil: true
#  validates :work_ranking_valid?, if: :work_ranking 


  def self.find_by_birth_month_day_and_role(month, day, role)
    # todo: validate month and day
    Person.all.map(&:to_h) 
  end

  def to_h
=begin
{ name: "Gemma Arterton", 
	photoUrl: "https://images-na.ssl-images-amazon.com/images/M/MV5BOTAwNTMwMzE5OF5BMl5BanBnXkFtZTgwMjYwNzI2MjE@._V1_UX140_CR0,0,140,209_AL_.jpg", 
	profileUrl: "http://www.imdb.com/name/nm2605345", 
	mostKnownWork: 
	{ title: "Prince of Persia: The Sands of Time", 
	url: "http://www.imdb.com/title/tt0473075/", 
	rating: 6.6, 
	director: "Louis Leterrier" } 
	}, ... ] } 
=end
    most_known_work = !works.empty? ? works.first.to_h : {}
    return { name: name, photoUrl: photo_url, profileUrl: profile_url, mostKnownWork: most_known_work }
  end
end
