class Work < ActiveRecord::Base

  DOMAIN = "https://www.imdb.com"
  has_many :crew_members, dependent: :destroy
  has_many :people, through: :crew_members
  has_many :roles, through: :crew_members

  enum category: [ :movie, :tv_show ]
  
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true

  def director_or_creator
    role = category ? "Creator" : "Director"
    #roles.filter(name: role)
  end
  
  def to_h
=begin
mostKnownWork: 
	{ title: "Prince of Persia: The Sands of Time", 
	url: "http://www.imdb.com/title/tt0473075/", 
	rating: 6.6, 
	director: "Louis Leterrier" } 
	},
=end     
    return { title: title, url: url, rating: rating }
  end

  def url
    "#{DOMAIN}#{self[:url]}"
  end  
end
