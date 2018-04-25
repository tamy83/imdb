class Person < ActiveRecord::Base
  has_many :work, through: crew_member

  validates :name, presence: true
  validates :photo_url, format: URI::regexp(%w(http https))
  validates :profile_url, format: URI::regexp(%w(http https))
  validates :birthdate, format: 
  def initialize(name, photo_url, profile_url, birthdate, work_ranking)
    @name = name
    @photo_url = photo_url
    @profile_url = profile_url
    @birthdate = birthdate
    @work_ranking = work_ranking
  end
end
