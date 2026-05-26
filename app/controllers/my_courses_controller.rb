# "Meine Kurse" — die Anmeldungen der eingeloggten Lernenden, nach Status gruppiert.
class MyCoursesController < ApplicationController
  layout "marketplace"

  def index
    @enrollments = current_user.enrollments.includes(course: :category).to_a
    @confirmed  = @enrollments.select { |e| e.status == "confirmed" }
    @waitlisted = @enrollments.select { |e| e.status == "waitlisted" }
    @done       = @confirmed.select { |e| e.course.status == "done" }
    @active     = @confirmed.reject { |e| e.course.status == "done" }
  end
end
