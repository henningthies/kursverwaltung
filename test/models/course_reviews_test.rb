require "test_helper"

# Tests für die Review-Methoden am Course-Modell.
class CourseReviewsTest < ActiveSupport::TestCase
  setup do
    @course = courses(:claude_code)
    @lena   = users(:learner)
    @karim  = users(:learner2)
  end

  # claude_code hat 2 sichtbare Bewertungen (lena: 5, karim: 4) und keine private.
  test "average_rating berechnet Durchschnitt nur über visible-Reviews" do
    avg = @course.average_rating
    assert_in_delta 4.5, avg, 0.01
  end

  test "reviews_count zählt nur visible-Reviews" do
    assert_equal 2, @course.reviews_count
  end

  test "private Review (visible: false) geht nicht in Schnitt/Anzahl ein" do
    # prompt_engineering hat eine private Bewertung (lena_prompt_private, rating 3)
    course = courses(:prompt_engineering)
    assert_nil course.average_rating
    assert_equal 0, course.reviews_count
  end

  test "average_rating ist nil ohne sichtbare Bewertungen" do
    course = courses(:rails_performance)   # keine Reviews in Fixtures
    assert_nil course.average_rating
  end

  test "reviewed_by? gibt true zurück wenn User diesen Kurs bewertet hat" do
    assert @course.reviewed_by?(@lena)
    assert @course.reviewed_by?(@karim)
  end

  test "reviewed_by? gibt false zurück wenn User diesen Kurs noch nicht bewertet hat" do
    assert_not @course.reviewed_by?(users(:admin))
  end

  test "reviewed_by? gibt false zurück bei nil (Gast)" do
    assert_not @course.reviewed_by?(nil)
  end

  test "destroying a course destroys its reviews" do
    course = courses(:claude_code)
    review_count = course.reviews.count
    assert review_count > 0
    assert_difference "Review.count", -review_count do
      course.destroy
    end
  end
end
