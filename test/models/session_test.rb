require "test_helper"

class SessionTest < ActiveSupport::TestCase
  setup do
    @session = sessions(:claude_termin_1)
  end

  test "requires a title" do
    @session.title = ""
    assert_not @session.valid?
    assert_includes @session.errors[:title], "muss ausgefüllt werden"
  end

  test "requires a course" do
    @session.course = nil
    assert_not @session.valid?
  end

  test "ordered scope sorts sessions by starts_at" do
    ordered = courses(:claude_code).sessions.ordered.to_a
    assert_equal [ sessions(:claude_termin_1), sessions(:claude_termin_2) ], ordered
  end
end
