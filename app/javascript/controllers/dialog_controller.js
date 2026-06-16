import { Controller } from "@hotwired/stimulus"

// Öffnet und schließt ein <dialog>-Element.
export default class extends Controller {
  static targets = ["modal"]

  open() {
    this.modalTarget.showModal()
  }

  close() {
    this.modalTarget.close()
  }
}
