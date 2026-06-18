class ReviewsController < ApplicationController
  before_action :set_course
  before_action :require_login,  only: %i[create]
  before_action :require_admin,  only: %i[destroy]

  # POST /courses/:course_id/reviews
  def create
    @review = @course.reviews.new(review_params)
    @review.user = current_user

    if @review.save
      redirect_to catalog_course_path(@course), notice: "Danke für deine Bewertung!"
    else
      redirect_to catalog_course_path(@course), alert: @review.errors.full_messages.to_sentence
    end
  end

  # DELETE /courses/:course_id/reviews/:id
  def destroy
    @review = @course.reviews.find(params[:id])
    @review.destroy
    redirect_to course_path(@course), notice: "Bewertung wurde gelöscht."
  end

  private
    def set_course
      # create: nur published Kurse (Lernende dürfen nur aktive Kurse bewerten)
      # destroy: alle Kurse (Admin sieht alle)
      if action_name == "create"
        @course = Course.published.find(params[:course_id])
      else
        @course = Course.find(params[:course_id])
      end
    end

    def review_params
      params.expect(review: %i[rating comment anonymous visible])
    end
end
