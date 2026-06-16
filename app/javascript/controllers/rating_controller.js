import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field"]

  set(event) {
    event.preventDefault()
    const rating = event.target.dataset.rating
    this.fieldTarget.value = rating

    // Update visual state: highlight selected stars
    this.element.querySelectorAll("button[data-rating]").forEach((btn) => {
      const btnRating = parseInt(btn.dataset.rating)
      if (btnRating <= rating) {
        btn.classList.add("text-amber-400")
        btn.classList.remove("text-gray-300")
      } else {
        btn.classList.remove("text-amber-400")
        btn.classList.add("text-gray-300")
      }
    })
  }
}
