# Öffentlicher Marketplace (lernenden-zugewandt), getrennt vom Admin-CoursesController.
class CatalogController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  layout "marketplace"

  def index
    @categories = Category.ordered
    @category = Category.find_by(slug: params[:category])
    # Öffentlich nur aktive Kurse; Filter über ?category=<slug>.
    @courses = Course.published.in_category(@category).ordered
  end

  def show
    # Öffentlich sichtbar sind nur aktive Kurse; alles andere ist hier nicht auffindbar.
    @course = Course.published.find(params[:id])
    @sessions = @course.sessions.ordered
  end
end
