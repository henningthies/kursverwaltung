class CoursesController < ApplicationController
  before_action :set_course, only: %i[show edit update destroy]

  def index
    @courses = Course.ordered
  end

  def show
    @sessions = @course.sessions.ordered
    @session = @course.sessions.new
    @confirmed_enrollments  = @course.enrollments.confirmed.oldest_first.includes(:participant)
    @waitlisted_enrollments = @course.enrollments.waitlisted.oldest_first.includes(:participant)
    @enrollment_params = {}
  end

  def new
    @course = Course.new
  end

  def edit
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      redirect_to @course, notice: "Kurs wurde erstellt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @course.update(course_params)
      redirect_to @course, notice: "Kurs wurde aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy
    redirect_to courses_path, notice: "Kurs wurde gelöscht."
  end

  private
    def set_course
      @course = Course.find(params[:id])
    end

    def course_params
      params.expect(course: %i[title status description instructor])
    end
end
