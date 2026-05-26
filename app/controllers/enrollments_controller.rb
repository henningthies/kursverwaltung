class EnrollmentsController < ApplicationController
  before_action :set_course

  def create
    @participant = Participant.find_or_initialize_by(email: enrollment_params[:email])
    @participant.name = enrollment_params[:name] if @participant.new_record?

    if @participant.invalid?
      @sessions = @course.sessions.ordered
      @session = @course.sessions.new
      @confirmed_enrollments  = @course.enrollments.confirmed.oldest_first.includes(:participant)
      @waitlisted_enrollments = @course.enrollments.waitlisted.oldest_first.includes(:participant)
      render "courses/show", status: :unprocessable_entity
      return
    end

    @participant.save!
    enrollment = @course.enroll(@participant)

    if enrollment.status == "confirmed"
      redirect_to @course, notice: "Anmeldung bestätigt."
    else
      redirect_to @course, notice: "Sie stehen auf der Warteliste."
    end
  end

  def destroy
    @enrollment = @course.enrollments.find(params[:id])
    @enrollment.cancel
    redirect_to @course, notice: "Abmeldung gespeichert."
  end

  private
    def set_course
      @course = Course.find(params[:course_id])
    end

    def enrollment_params
      params.expect(enrollment: %i[name email])
    end
end
