import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slider", "numberInput"]
  static values = { recalculateUrl: String, mealIngredientId: String }

  connect() {
    this.timeout = null
  }

  syncFromSlider() {
    if (this.hasNumberInputTarget && this.hasSliderTarget) {
      this.numberInputTarget.value = this.sliderTarget.value
    }
    this.debouncedSubmit()
  }

  syncFromNumber() {
    if (this.hasSliderTarget && this.hasNumberInputTarget) {
      this.sliderTarget.value = this.numberInputTarget.value
    }
    this.debouncedSubmit()
  }

  stepGrams(event) {
    const delta = parseInt(event.currentTarget.dataset.delta || 0, 10)
    let currentGrams = parseInt(this.numberInputTarget.value || 0, 10)
    let newGrams = Math.max(0, currentGrams + delta)

    this.numberInputTarget.value = newGrams
    if (this.hasSliderTarget) {
      this.sliderTarget.value = newGrams
    }
    this.debouncedSubmit()
  }

  debouncedSubmit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.submitRecalculate()
    }, 150)
  }

  submitRecalculate() {
    const grams = this.numberInputTarget ? this.numberInputTarget.value : this.sliderTarget.value
    const url = this.recalculateUrlValue

    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "text/vnd.turbo-stream.html, text/html, application/xhtml+xml",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content")
      },
      body: new URLSearchParams({
        meal_ingredient_id: this.mealIngredientIdValue,
        grams: grams
      })
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
    .catch(error => console.error("Recalculate error:", error))
  }
}
