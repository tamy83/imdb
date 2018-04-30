class Person < ActiveRecord::Base

  has_many :crew_members, dependent: :destroy
  has_many :works, through: :crew_members
  has_many :roles, through: :crew_members

  validates :name, presence: true
  validates :photo_url, format: URI::regexp(%w(http https)), allow_nil: true
  # store relative path only
#  validates :profile_url, format: URI::regexp(%w(http https)), allow_nil: true

  #todo: add column known_for_ranking, comma delimited string of work_ids that corresponds users known for works

  def self.find_by_birth_month_day_and_role(month, day, role)
    # todo: validate month and day
    Person.where('extract(month from birthdate) = ? AND extract(day from birthdate) = ?', month.to_i, day.to_i).map(&:to_h)
  end

  def to_h
    most_known_work = !works.empty? ? works.first.to_h : {}
    return { name: name, photoUrl: photo_url, profileUrl: profile_url, mostKnownWork: most_known_work }
  end
end
