class CrewMember < ActiveRecord::Base

  belongs_to :person
  belongs_to :work
  has_many :roles

end
