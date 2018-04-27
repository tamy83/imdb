class SearchController < ApplicationController

  def find
    mmdd = params[:birth_monthday]
    mm = mmdd.split('-').first
    dd = mmdd.split('-').last
    role = params[:role]
    people = Person.find_by_birth_month_day_and_role(mm,dd,role)
    render :json => people
  end

end
