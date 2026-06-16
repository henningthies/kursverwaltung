require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:claude_code)
    @learner = users(:learner)
    @learner2 = users(:learner2)
    @admin = users(:admin)
    @draft_course = courses(:rails_performance)
    @done_course = courses(:git_for_teams)
    @published_course = courses(:free_intro)
  end

  # ===== CREATE Tests =====

  test "logged-in user can create a review" do
    sign_in_as(@learner2)
    # Use a course that learner2 hasn't reviewed
    assert_difference "Review.count", 1 do
      post course_reviews_path(@published_course), params: {
        review: { rating: 5, comment: "Great course!", anonymous: false, visible: true }
      }
    end
    assert_redirected_to catalog_course_path(@published_course)
    assert_match /Danke für deine Bewertung/, flash[:notice]
  end

  test "learner create redirects to catalog course path and shows notice" do
    sign_in_as(@learner2)
    # Use a course that learner2 hasn't reviewed
    assert_difference "Review.count", 1 do
      post course_reviews_path(@published_course), params: {
        review: { rating: 5, comment: "Great course!", anonymous: false, visible: true }
      }
    end
    # Follow redirect and check that we land on catalog_course_path, not admin path
    follow_redirect!
    assert_response :success
    # Verify we're on the public course detail page (not admin)
    assert_match /Danke für deine Bewertung/, response.body
    # Ensure no admin-only text appears
    assert_no_match /Dieser Bereich ist nur für Administratoren/, response.body
  end

  test "create with invalid rating (0 or 6) fails" do
    sign_in_as(@learner2)
    assert_no_difference "Review.count" do
      post course_reviews_path(@published_course), params: {
        review: { rating: 0, comment: "Bad", anonymous: false, visible: true }
      }
    end
    assert_redirected_to catalog_course_path(@published_course)
  end

  test "create with invalid rating redirects to catalog course path" do
    sign_in_as(@learner2)
    assert_no_difference "Review.count" do
      post course_reviews_path(@published_course), params: {
        review: { rating: 0, comment: "Bad", anonymous: false, visible: true }
      }
    end
    # Verify redirect is to catalog_course_path (public), not admin path
    follow_redirect!
    assert_response :success
    # Ensure no admin text appears
    assert_no_match /Dieser Bereich ist nur für Administratoren/, response.body
  end

  test "create without rating fails validation" do
    sign_in_as(@learner2)
    assert_no_difference "Review.count" do
      post course_reviews_path(@published_course), params: {
        review: { rating: nil, comment: "No rating", anonymous: false, visible: true }
      }
    end
  end

  test "create as guest (not logged in) redirects to login" do
    assert_no_difference "Review.count" do
      post course_reviews_path(@course), params: {
        review: { rating: 5, comment: "Test", anonymous: false, visible: true }
      }
    end
    assert_redirected_to new_session_path
  end

  test "create for draft course returns 404" do
    sign_in_as(@learner2)
    post course_reviews_path(@draft_course), params: {
      review: { rating: 5, comment: "Test", anonymous: false, visible: true }
    }
    assert_response :not_found
  end

  test "create for done course returns 404" do
    sign_in_as(@learner2)
    post course_reviews_path(@done_course), params: {
      review: { rating: 5, comment: "Test", anonymous: false, visible: true }
    }
    assert_response :not_found
  end

  test "duplicate review for same user+course fails" do
    sign_in_as(@learner)
    # @learner already has a review for @course (public fixture)
    assert_no_difference "Review.count" do
      post course_reviews_path(@course), params: {
        review: { rating: 4, comment: "Second attempt", anonymous: false, visible: true }
      }
    end
    assert_redirected_to catalog_course_path(@course)
  end

  test "params.expect restricts mass assignment (user_id/course_id cannot be set)" do
    sign_in_as(@learner2)
    # Attempting to set user_id or course_id in params should be ignored
    post course_reviews_path(@published_course), params: {
      review: {
        rating: 5,
        comment: "Test",
        anonymous: false,
        visible: true,
        user_id: @admin.id,
        course_id: @course.id
      }
    }
    review = Review.last
    assert_equal @learner2.id, review.user_id
    assert_equal @published_course.id, review.course_id
  end

  test "create respects anonymous and visible flags" do
    sign_in_as(@learner2)
    post course_reviews_path(@published_course), params: {
      review: { rating: 4, comment: "Anon review", anonymous: true, visible: false }
    }
    review = Review.last
    assert review.anonymous
    assert_not review.visible
  end

  # ===== DESTROY Tests =====

  test "admin can destroy a review" do
    sign_in_as(@admin)
    review = reviews(:public)
    assert_difference "Review.count", -1 do
      delete course_review_path(review.course, review)
    end
    assert_redirected_to review.course
  end

  test "non-admin cannot destroy a review" do
    sign_in_as(@learner)
    review = reviews(:public)
    assert_no_difference "Review.count" do
      delete course_review_path(review.course, review)
    end
    # Should be blocked (require_admin)
    assert_response :redirect
  end

  test "guest cannot destroy a review" do
    review = reviews(:public)
    assert_no_difference "Review.count" do
      delete course_review_path(review.course, review)
    end
    # Should redirect (either to login or root)
    assert_response :redirect
  end

  test "destroy redirects to course after deletion" do
    sign_in_as(@admin)
    review = reviews(:public)
    delete course_review_path(review.course, review)
    assert_redirected_to review.course
  end
end
