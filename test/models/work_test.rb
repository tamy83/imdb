require 'test_helper'

class WorkTest < ActiveSupport::TestCase
  test "valid work" do
    work = Work.new(title: "Prince of Persia: The Sands of Time", url: "/title/tt0473075/", rating: 6.6, category: Work.categories[:movie])
    assert work.valid?
  end

  test "invalid without title" do
    work = Work.new(url: "/title/tt0473075/", rating: 6.6, category: Work.categories[:movie])
    refute work.valid?, 'work missing title'
    refute_empty work.errors[:title]
  end

  test "invalid rating greater than 10" do
    work = Work.new(title: "Prince of Persia: The Sands of Time", url: "/title/tt0473075/", rating: 11, category: Work.categories[:movie])
    refute work.valid?, 'work rating greater than 10'
    refute_empty work.errors[:rating]
  end

  test "invalid rating less than 0" do
    work = Work.new(title: "Prince of Persia: The Sands of Time", url: "/title/tt0473075/", rating: -5, category: Work.categories[:movie])
    refute work.valid?, 'work rating less than 0'
    refute_empty work.errors[:rating]
  end

end
