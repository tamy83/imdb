class CrewMember < ActiveRecord::Base

  include Person

  belongs_to :work
  has_many :roles

# role_ranking???
end
