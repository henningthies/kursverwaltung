require "test_helper"

class CourseTest < ActiveSupport::TestCase
  setup do
    @course = courses(:claude_code)
  end

  test "requires a title" do
    @course.title = ""
    assert_not @course.valid?
    assert_includes @course.errors[:title], "muss ausgefüllt werden"
  end

  test "rejects a status outside STATUSES" do
    @course.status = "archived"
    assert_not @course.valid?
    assert_includes @course.errors[:status], "ist kein gültiger Wert"
  end

  test "accepts every status in STATUSES" do
    Course::STATUSES.each do |status|
      @course.status = status
      assert @course.valid?, "#{status} sollte gültig sein"
    end
  end

  test "ordered scope sorts courses by title" do
    titles = Course.ordered.pluck(:title)
    assert_equal titles.sort, titles
  end

  test "destroying a course destroys its sessions" do
    assert_equal 2, @course.sessions.count
    assert_difference "Session.count", -2 do
      @course.destroy
    end
  end
end
