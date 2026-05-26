class CoursesController < ApplicationController
  before_action :require_admin
  before_action :set_course, only: %i[show edit update destroy participants]

  def index
    # BEWUSSTE DEMO-SCHWACHSTELLE (T3 Performance): kein includes / counter_cache.
    # Die Zähler in der View (enrollments/sessions je Kurs) erzeugen so eine N+1-Query.
    # NICHT vorab fixen — die Optimierung ist die Live-Demo.
    @courses = Course.ordered
  end

  def show
    @sessions = @course.sessions.ordered
    @session = @course.sessions.new
    @confirmed_enrollments  = @course.enrollments.confirmed.oldest_first.includes(:participant)
    @waitlisted_enrollments = @course.enrollments.waitlisted.oldest_first.includes(:participant)
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

  # BEWUSSTE DEMO-SCHWACHSTELLE (T3 Security): exponiert Teilnehmer-PII (Name + E-Mail)
  # ungefiltert als JSON, ohne Auth, und loggt die PII zusätzlich. NICHT fixen — das
  # Erkennen im PR-Review und die Redaktion/Filterung sind die Live-Demo.
  def participants
    Rails.logger.info("Teilnehmer-Export für #{@course.title}: #{@course.participants.to_json}")
    render json: @course.participants.select(:id, :name, :email)
  end

  private
    def set_course
      @course = Course.find(params[:id])
    end

    def course_params
      params.expect(course: %i[title status description instructor capacity])
    end
end
