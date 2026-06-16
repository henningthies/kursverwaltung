class ReviewsController < ApplicationController
  allow_unauthenticated_access only: %w[]
  before_action :require_login, only: :create
  before_action :require_admin, only: :destroy
  before_action :set_course_published

  def create
    @review = @course.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to catalog_course_path(@course), notice: "Danke für deine Bewertung!"
    else
      redirect_to catalog_course_path(@course), alert: "Bewertung konnte nicht gespeichert werden."
    end
  end

  def destroy
    @review = Review.find(params[:id])
    course = @review.course
    @review.destroy
    redirect_to course, notice: "Bewertung gelöscht."
  end

  private

  def set_course_published
    @course = Course.published.find(params[:course_id])
  end

  def review_params
    params.expect(review: %i[rating comment anonymous visible])
  end
end
