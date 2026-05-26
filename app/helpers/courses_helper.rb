module CoursesHelper
  STATUS_LABELS = {
    "draft"  => "Entwurf",
    "active" => "Aktiv",
    "done"   => "Abgeschlossen"
  }.freeze

  STATUS_CLASSES = {
    "draft"  => "bg-gray-100 text-gray-700",
    "active" => "bg-green-100 text-green-800",
    "done"   => "bg-blue-100 text-blue-800"
  }.freeze

  def course_status_label(course)
    STATUS_LABELS.fetch(course.status, course.status)
  end

  def course_status_badge(course)
    classes = STATUS_CLASSES.fetch(course.status, "bg-gray-100 text-gray-700")
    tag.span course_status_label(course),
      class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{classes}"
  end
end
