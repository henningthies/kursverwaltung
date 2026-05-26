class SessionsController < ApplicationController
  before_action :set_course

  def create
    @session = @course.sessions.new(session_params)

    if @session.save
      redirect_to @course, notice: "Termin wurde hinzugefügt."
    else
      @sessions = @course.sessions.ordered
      @confirmed_enrollments  = @course.enrollments.confirmed.oldest_first.includes(:participant)
      @waitlisted_enrollments = @course.enrollments.waitlisted.oldest_first.includes(:participant)
      render "courses/show", status: :unprocessable_entity
    end
  end

  def destroy
    @session = @course.sessions.find(params[:id])
    @session.destroy
    redirect_to @course, notice: "Termin wurde gelöscht."
  end

  private
    def set_course
      @course = Course.find(params[:course_id])
    end

    def session_params
      params.expect(session: %i[title starts_at])
    end
end
