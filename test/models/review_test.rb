require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  setup do
    @lena  = users(:learner)
    @karim = users(:learner2)
    @course = courses(:claude_code)
  end

  # --- Validierungen ---
  # Für Validierungs-Tests ohne Uniqueness-Konflikt: admin hat noch keine Review für claude_code.

  test "valid review with all required fields" do
    review = Review.new(user: users(:admin), course: @course, rating: 5)
    assert review.valid?
  end

  test "rating is required" do
    review = Review.new(user: users(:admin), course: @course, rating: nil)
    assert_not review.valid?
    assert_includes review.errors[:rating], "muss ausgefüllt werden"
  end

  test "rating must be at least 1" do
    review = Review.new(user: users(:admin), course: @course, rating: 0)
    assert_not review.valid?
  end

  test "rating must be at most 5" do
    review = Review.new(user: users(:admin), course: @course, rating: 6)
    assert_not review.valid?
  end

  test "rating 1 through 5 are all valid" do
    (1..5).each do |r|
      review = Review.new(user: users(:admin), course: courses(:rails_performance), rating: r)
      assert review.valid?, "rating #{r} sollte gültig sein"
    end
  end

  test "comment is optional" do
    review = Review.new(user: users(:admin), course: @course, rating: 4, comment: nil)
    assert review.valid?
  end

  # --- Uniqueness ---

  test "one user can review a course only once" do
    # learner hat claude_code bereits bewertet (Fixture: lena_claude_code)
    duplicate = Review.new(user: @lena, course: @course, rating: 3)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "hat diesen Kurs bereits bewertet"
  end

  test "different users can each review the same course" do
    # learner2 hat claude_code bereits bewertet (Fixture: karim_claude_code_anon) —
    # ein dritter User (admin) darf ebenfalls bewerten.
    review = Review.new(user: users(:admin), course: @course, rating: 2)
    assert review.valid?
  end

  # --- display_name ---

  test "display_name returns user name when not anonymous" do
    review = reviews(:lena_claude_code)
    assert_equal "Lena Lernerin", review.display_name
  end

  test "display_name returns Anonym when anonymous" do
    review = reviews(:karim_claude_code_anon)
    assert review.anonymous?
    assert_equal "Anonym", review.display_name
  end

  # --- scope :visible ---

  test "visible scope returns only visible reviews" do
    visible_ids = Review.visible.pluck(:id)
    assert_includes visible_ids, reviews(:lena_claude_code).id
    assert_includes visible_ids, reviews(:karim_claude_code_anon).id
    assert_not_includes visible_ids, reviews(:lena_prompt_private).id
  end

  # --- Defaults ---

  test "visible defaults to true" do
    review = Review.new
    assert review.visible
  end

  test "anonymous defaults to false" do
    review = Review.new
    assert_not review.anonymous
  end
end
