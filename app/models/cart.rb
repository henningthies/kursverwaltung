# Session-basierter Warenkorb (kein DB-Modell). Kapselt die Kurs-IDs aus der Session
# und liefert die zugehörigen Kurse + Summe. Siehe ADR 0006.
class Cart
  def initialize(course_ids)
    @course_ids = Array(course_ids).map(&:to_i).uniq
  end

  attr_reader :course_ids

  def courses
    @courses ||= Course.where(id: course_ids).to_a
  end

  def add(course_id)
    @course_ids = (course_ids + [course_id.to_i]).uniq
  end

  def remove(course_id)
    @course_ids = course_ids - [course_id.to_i]
  end

  def include?(course_id)
    course_ids.include?(course_id.to_i)
  end

  def total_cents
    courses.sum(&:price_cents)
  end

  def size
    courses.size
  end

  def empty?
    courses.empty?
  end
end
