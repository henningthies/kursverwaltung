module ApplicationHelper
  ENROLLMENT_STATUS_LABELS = {
    "confirmed"  => "Bestätigt",
    "waitlisted" => "Warteliste",
    "cancelled"  => "Abgesagt"
  }.freeze

  ENROLLMENT_STATUS_CLASSES = {
    "confirmed"  => "bg-green-100 text-green-800",
    "waitlisted" => "bg-amber-100 text-amber-800",
    "cancelled"  => "bg-gray-100 text-gray-500"
  }.freeze

  def enrollment_status_badge(enrollment)
    label   = ENROLLMENT_STATUS_LABELS.fetch(enrollment.status, enrollment.status)
    classes = ENROLLMENT_STATUS_CLASSES.fetch(enrollment.status, "bg-gray-100 text-gray-700")
    tag.span label,
      class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{classes}"
  end
end
