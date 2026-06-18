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

    euros = price_cents.to_i / 100.0
    format("%.2f €", euros).sub(".", ",")
  end

  STAR_SVG = '<path d="M9.05 2.93c.3-.92 1.6-.92 1.9 0l1.36 4.18a1 1 0 00.95.69h4.4c.97 0 1.37 1.24.59 1.81l-3.56 2.59a1 1 0 00-.36 1.12l1.36 4.18c.3.92-.76 1.69-1.54 1.12l-3.56-2.59a1 1 0 00-1.18 0L6.25 18.6c-.78.57-1.84-.2-1.54-1.12l1.36-4.18a1 1 0 00-.36-1.12L2.15 9.6c-.78-.57-.38-1.81.59-1.81h4.4a1 1 0 00.95-.69z"/>'.html_safe

  # Gibt 5 Sterne als Inline-SVGs zurück (amber = ausgefüllt, grau = leer).
  # Optionaler count-Parameter hängt "N Bewertungen" an.
  def star_rating(value, count: nil, size: "w-4 h-4")
    return "" if value.nil?

    rounded = value.to_f.round(1)
    full    = rounded.floor
    half    = (rounded - full) >= 0.5 ? 1 : 0
    empty   = 5 - full - half

    stars = "".html_safe
    full.times do
      stars += content_tag(:svg, STAR_SVG, class: "#{size} text-amber-400", fill: "currentColor", viewBox: "0 0 20 20")
    end
    half.times do
      stars += content_tag(:svg, STAR_SVG, class: "#{size} text-amber-300", fill: "currentColor", viewBox: "0 0 20 20")
    end
    empty.times do
      stars += content_tag(:svg, STAR_SVG, class: "#{size} text-gray-300", fill: "currentColor", viewBox: "0 0 20 20")
    end

    result = content_tag(:span, stars, class: "inline-flex items-center gap-0.5")
    if count
      label = count == 1 ? "Bewertung" : "Bewertungen"
      result += " ".html_safe + content_tag(:span, "#{rounded.to_s.sub('.', ',')} · #{count} #{label}", class: "text-sm text-gray-600")
    end
    result
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
