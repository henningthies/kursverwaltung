# Public marketplace (learner-facing), separate from the admin CoursesController.
class CatalogController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  layout "marketplace"

  # Whitelist of allowed sort values → scope; guards against arbitrary param input.
  SORTS = { "title" => :ordered, "price_asc" => :by_price_asc, "price_desc" => :by_price_desc }.freeze
  private_constant :SORTS

  def index
    @categories = Category.ordered
    @category = Category.find_by(slug: params[:category])
    @sort = SORTS.key?(params[:sort]) ? params[:sort] : "title"
    # Public listing shows only active courses; filter via ?category=<slug>, sort via ?sort=.
    @courses = Course.published.in_category(@category).public_send(SORTS[@sort])

    # Gruppierte Abfrage für Sterne auf den Kurs-Karten (kein N+1 einführen).
    course_ids = @courses.map(&:id)
    @ratings_by_course = Review.visible.where(course_id: course_ids)
                               .group(:course_id)
                               .average(:rating)
    @counts_by_course  = Review.visible.where(course_id: course_ids)
                               .group(:course_id)
                               .count
  end

  def show
    # Only active courses are publicly visible; anything else is not findable here.
    @course   = Course.published.find(params[:id])
    @sessions = @course.sessions.ordered
    @reviews  = @course.reviews.visible.includes(:user).order(created_at: :desc)
  end
end
