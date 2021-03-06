class Person < ActiveRecord::Base

  DOMAIN = "https://www.imdb.com"
  has_many :crew_members, dependent: :destroy
  has_many :works, through: :crew_members
  has_many :roles, through: :crew_members

  validates :photo_url, format: URI::regexp(%w(http https)), allow_nil: true
  validate :work_rankings_valid

  def self.find_by_birth_month_day_and_role(month, day, role)
    role_obj = Role.find_by(name: role)
    if role_obj.blank?
      self.find_by_birth_month_day(month, day) 
    else
      Person.where('extract(month from birthdate) = ? AND extract(day from birthdate) = ?', month.to_i, day.to_i).select{|p| p.roles.include? role_obj}.map(&:to_h)
    end
  end
 
  def self.find_by_birth_month_day(month, day)
    # todo: validate month and day
    Person.where('extract(month from birthdate) = ? AND extract(day from birthdate) = ?', month.to_i, day.to_i).map(&:to_h)
  end

  def to_h
    return { name: name, photoUrl: photo_url, profileUrl: profile_url, mostKnownWork: most_known_work.to_h }
  end

  def profile_url
    "#{DOMAIN}#{self[:profile_url]}"
  end

  def work_rankings_valid
    return true if work_rankings.nil?
    work_ids = work_rankings_as_array
    work_ids.each { |id|
      return false if Work.find_by(id: id.to_i).nil?
    }
    return true
  end
  
  def most_known_work
    Work.find_by(id: work_rankings_as_array.first.to_i)
  end

  def set_most_known_work(work)
    new_rankings = work_rankings_as_array
    new_rankings.delete(work.id.to_s)
    new_rankings = new_rankings.join(',')
    new_rankings.insert(0,"#{work.id},")
    self.work_rankings = new_rankings
    self.save
  end

  def work_rankings_as_array
    return (work_rankings) ? work_rankings.split(',') : []
  end
end
