import { Controller } from "@hotwired/stimulus"

// Sterne-Eingabe: hebt Sterne beim Hover und Klick hervor; setzt das hidden field.
export default class extends Controller {
  static targets = ["star", "input"]
  static values  = { rating: Number }

  connect() {
    this.updateStars(this.ratingValue)
  }

  highlight(event) {
    const value = parseInt(event.currentTarget.dataset.value)
    this.updateStars(value)
  }

  reset() {
    this.updateStars(this.ratingValue)
  }

  select(event) {
    const value = parseInt(event.currentTarget.dataset.value)
    this.ratingValue = value
    this.inputTarget.value = value
    this.updateStars(value)
  }

  updateStars(upTo) {
    this.starTargets.forEach((star, i) => {
      if (i < upTo) {
        star.classList.remove("text-gray-300")
        star.classList.add("text-amber-400")
      } else {
        star.classList.remove("text-amber-400")
        star.classList.add("text-gray-300")
      }
    })
  }
}
