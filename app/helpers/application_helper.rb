module ApplicationHelper
  # Aktiv-Zustand für die Marketplace-Navigation: hebt den Link der aktuellen Sektion hervor.
  def nav_link_class(active)
    if active
      "text-violet-700 font-semibold"
    else
      "text-gray-600 hover:text-gray-900"
    end
  end

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

  ORDER_STATUS_LABELS = {
    "pending" => "Offen",
    "paid"    => "Bezahlt",
    "failed"  => "Fehlgeschlagen"
  }.freeze

  ORDER_STATUS_CLASSES = {
    "pending" => "bg-amber-100 text-amber-800",
    "paid"    => "bg-green-100 text-green-800",
    "failed"  => "bg-gray-100 text-gray-500"
  }.freeze

  def order_status_badge(order)
    label   = ORDER_STATUS_LABELS.fetch(order.status, order.status)
    classes = ORDER_STATUS_CLASSES.fetch(order.status, "bg-gray-100 text-gray-700")
    tag.span label,
      class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{classes}"
  end

  # Geld als Integer-Cents → deutsche Anzeige. price_cents = 0 → "Gratis".
  def price_display(price_cents)
    return "Gratis" if price_cents.to_i.zero?

    euros, cents = price_cents.to_i.divmod(100)
    grouped_euros = euros.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
    format("%s,%02d €", grouped_euros, cents)
  end

  # Verfügbarkeits-Badge für Kurs-Karten/Detail (Gratis / Fast ausgebucht / Ausgebucht).
  def course_availability_badge(course)
    if course.full?
      tag.span "Ausgebucht",
        class: "inline-flex items-center gap-1 rounded-full bg-gray-100 px-2.5 py-0.5 text-xs font-medium text-gray-600"
    elsif course.almost_full?
      tag.span "Fast ausgebucht",
        class: "inline-flex items-center gap-1 rounded-full bg-amber-100 px-2.5 py-0.5 text-xs font-medium text-amber-800"
    elsif course.free?
      tag.span "Gratis",
        class: "inline-flex items-center gap-1 rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-800"
    end
  end
end
