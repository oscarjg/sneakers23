const dom = {}

function getProductIds() {
    const products = document.querySelectorAll(".product-listing")

    return Array.from(products).map((el) => {return el.dataset.productId})
}
dom.getProductIds = getProductIds

function replaceProductComingSoon(productId, sizeHtml) {
    const name = `.product-soon-${productId}`
    const comingSoonElement = document.querySelectorAll(name)

    comingSoonElement.forEach((el) => {
        const fragment = document
            .createRange()
            .createContextualFragment(sizeHtml)

        el.replaceWith(fragment)
    })
}
dom.replaceProductComingSoon = replaceProductComingSoon

function updateItemLevel(itemId, level) {
  Array.from(document.querySelectorAll('.size-container__entry')).
    filter((el) => el.value == itemId).
    forEach((el) => {
      removeStockLevelClasses(el)
      el.classList.add(`size-container__entry--level-${level}`)
      el.disabled = level === "out"
    })
}

dom.updateItemLevel = updateItemLevel

function removeStockLevelClasses(el) {
  Array.from(el.classList).
    filter((s) => s.startsWith("size-container__entry--level-")).
    forEach((name) => el.classList.remove(name))
}

export default dom