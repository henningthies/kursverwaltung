require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course  = courses(:claude_code)
    @learner = users(:learner)
    @admin   = users(:admin)
    # rails_performance ist ein Draft-Kurs → nicht über Course.published auffindbar
    @draft_course = courses(:rails_performance)
  end

  # ---- create ----

  test "eingeloggter User kann Bewertung absenden" do
    # admin hat claude_code noch nicht bewertet (keine Fixture-Bewertung)
    sign_in_as(users(:admin))
    assert_difference "Review.count", 1 do
      post course_reviews_path(@course),
           params: { review: { rating: 5, comment: "Super!", anonymous: false, visible: true } }
    end
    assert_redirected_to catalog_course_path(@course)
    assert_equal "Danke für deine Bewertung!", flash[:notice]
  end

  test "ungültiges Rating speichert keinen Datensatz" do
    # admin hat claude_code noch nicht bewertet
    sign_in_as(users(:admin))
    assert_no_difference "Review.count" do
      post course_reviews_path(@course),
           params: { review: { rating: nil, comment: "", anonymous: false, visible: true } }
    end
    # Redirect zurück mit Alert
    assert_response :redirect
    assert flash[:alert].present?
  end

  test "rating = 0 wird abgelehnt" do
    sign_in_as(users(:admin))
    assert_no_difference "Review.count" do
      post course_reviews_path(@course),
           params: { review: { rating: 0, anonymous: false, visible: true } }
    end
    assert flash[:alert].present?
  end

  test "rating = 6 wird abgelehnt" do
    sign_in_as(users(:admin))
    assert_no_difference "Review.count" do
      post course_reviews_path(@course),
           params: { review: { rating: 6, anonymous: false, visible: true } }
    end
    assert flash[:alert].present?
  end

  test "Duplikat-Bewertung desselben Users wird verhindert" do
    # learner hat claude_code bereits bewertet (Fixture: lena_claude_code)
    sign_in_as(@learner)
    assert_no_difference "Review.count" do
      post course_reviews_path(@course),
           params: { review: { rating: 3, anonymous: false, visible: true } }
    end
    assert flash[:alert].present?
  end

  test "Gast wird bei create zu Login weitergeleitet" do
    assert_no_difference "Review.count" do
      post course_reviews_path(@course),
           params: { review: { rating: 4, anonymous: false, visible: true } }
    end
    assert_redirected_to new_session_path
  end

  test "create für Draft-Kurs gibt 404" do
    sign_in_as(@learner)
    post course_reviews_path(@draft_course),
         params: { review: { rating: 4, anonymous: false, visible: true } }
    assert_response :not_found
  end

  test "create setzt user_id aus current_user, nicht aus Params" do
    # admin hat noch keine Review für claude_code
    admin = users(:admin)
    sign_in_as(admin)
    assert_difference "Review.count", 1 do
      post course_reviews_path(@course),
           params: { review: { rating: 4, comment: "OK", anonymous: false, visible: true } }
    end
    review = Review.last
    assert_equal admin.id, review.user_id
  end

  # ---- destroy ----

  test "Admin kann Bewertung löschen" do
    sign_in_as(@admin)
    review = reviews(:lena_claude_code)
    assert_difference "Review.count", -1 do
      delete course_review_path(@course, review)
    end
    assert_redirected_to course_path(@course)
    assert_equal "Bewertung wurde gelöscht.", flash[:notice]
  end

  test "Nicht-Admin kann Bewertung nicht löschen" do
    sign_in_as(@learner)
    review = reviews(:karim_claude_code_anon)
    assert_no_difference "Review.count" do
      delete course_review_path(@course, review)
    end
    assert_redirected_to root_path
  end

  test "Gast kann Bewertung nicht löschen" do
    review = reviews(:lena_claude_code)
    assert_no_difference "Review.count" do
      delete course_review_path(@course, review)
    end
    # require_admin greift: nicht eingeloggt → root_path (kein dedizierter Login-Check nötig)
    assert_redirected_to root_path
  end
end
