class Work < ActiveRecord::Base

  DOMAIN = "https://www.imdb.com"
  has_many :crew_members, dependent: :destroy
  has_many :people, through: :crew_members
  has_many :roles, through: :crew_members

  enum category: [ :movie, :tv_show ]
  
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true

  def credits 
    role = Role.find_by(name: credit_str)
    crediters = CrewMembersRole.where(role: role, crew_member: self.crew_members)
    retval = []
    crediters.each { |c|
      retval.push(c.crew_member.person.name)
    }
    retval
  end
  
  def to_h
    retval = { title: title, url: url, rating: rating }
    retval[credit_str.to_sym] = self.credits
    return retval
  end

  def url
    "#{DOMAIN}#{self[:url]}"
  end

  def credit_str
    self.tv_show? ? "Creator" : "Director" 
  end
end
