require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  # Rating validations
  test "rating is required" do
    review = Review.new(user: users(:learner), course: courses(:claude_code), rating: nil)
    assert_not review.valid?
    assert review.errors[:rating].present?
  end

  test "rating must be between 1 and 5" do
    [ 0, 6, -1, 10 ].each do |invalid_rating|
      review = Review.new(user: users(:learner), course: courses(:claude_code), rating: invalid_rating)
      assert_not review.valid?, "rating #{invalid_rating} should be invalid"
      assert review.errors[:rating].present?
    end
  end

  test "rating 1 to 5 are valid" do
    (1..5).each do |valid_rating|
      review = Review.new(user: users(:admin), course: courses(:rails_performance), rating: valid_rating)
      # Just check that rating validation itself passes (may fail on other validations)
      assert review.valid? || !review.errors[:rating].present?, "rating #{valid_rating} should pass rating validation"
    end
  end

  # Uniqueness
  test "user can only review a course once" do
    review1 = Review.create!(user: users(:admin), course: courses(:rails_performance), rating: 5, visible: true)

    review2 = Review.new(user: users(:admin), course: courses(:rails_performance), rating: 4)
    assert_not review2.valid?
    assert review2.errors[:user_id].present?
    assert_match(/bereits bewertet/, review2.errors[:user_id].first)
  end

  test "different users can review the same course" do
    review1 = Review.create!(user: users(:admin), course: courses(:rails_performance), rating: 5)
    review2 = Review.create!(user: users(:learner), course: courses(:rails_performance), rating: 4)

    assert review1.persisted?
    assert review2.persisted?
  end

  # Display name
  test "display_name returns user name when not anonymous" do
    review = reviews(:public)
    assert_equal users(:learner).name, review.display_name
  end

  test "display_name returns 'Anonym' when anonymous" do
    review = reviews(:anonymous)
    assert_equal "Anonym", review.display_name
  end

  # Scope :visible
  test "scope :visible returns only visible reviews" do
    public_review = reviews(:public)
    private_review = reviews(:private)

    visible = Review.visible
    assert_includes visible, public_review
    assert_not_includes visible, private_review
  end

  # Course association
  test "review belongs to course" do
    review = reviews(:public)
    assert_equal courses(:claude_code), review.course
  end

  test "review belongs to user" do
    review = reviews(:public)
    assert_equal users(:learner), review.user
  end

  # Edge cases
  test "comment can be empty" do
    review = Review.create!(user: users(:learner2), course: courses(:prompt_engineering), rating: 3, comment: nil, visible: true)
    assert review.persisted?
    assert_nil review.comment
  end

  test "comment can be present" do
    review = Review.create!(user: users(:learner2), course: courses(:prompt_engineering), rating: 3, comment: "Great course!", visible: true)
    assert review.persisted?
    assert_equal "Great course!", review.comment
  end

  test "visible defaults to true" do
    review = Review.create!(user: users(:learner2), course: courses(:prompt_engineering), rating: 3)
    assert review.visible
  end

  test "anonymous defaults to false" do
    review = Review.create!(user: users(:learner2), course: courses(:prompt_engineering), rating: 3)
    assert_not review.anonymous
  end
end
