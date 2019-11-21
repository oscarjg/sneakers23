import { getCartHtml } from "./cartRenderer"

const dom = {}

dom.getProductIds = () => {
    const products = document.querySelectorAll(".product-listing")

    return Array.from(products).map((el) => {return el.dataset.productId})
}

dom.replaceProductComingSoon = (productId, sizeHtml) => {
    const name = `.product-soon-${productId}`
    const comingSoonElement = document.querySelectorAll(name)

    comingSoonElement.forEach((el) => {
        const fragment = document
            .createRange()
            .createContextualFragment(sizeHtml)

        el.replaceWith(fragment)
    })
}

dom.updateItemLevel = (itemId, level) => {
  Array.from(document.querySelectorAll('.size-container__entry')).
    filter((el) => el.value == itemId).
    forEach((el) => {
      removeStockLevelClasses(el)
      el.classList.add(`size-container__entry--level-${level}`)
      el.disabled = level === "out"
    })
}

dom.renderCartHtml = (cart) => {
  const cartContainer = document.getElementById("cart-container")
  cartContainer.innerHTML = getCartHtml(cart)
}

dom.onItemClick = (fn) => {
  document.addEventListener("click", (event) => {
      const targetEvent = event.target
      
      if (!targetEvent.matches(".size-container__entry")) { return }

      event.preventDefault()

      fn(targetEvent.value)
  })
}

dom.onRemoveItemClick = (fn) => {
  document.addEventListener("click", (event) => {
      const targetEvent = event.target
      
      if (!targetEvent.matches(".cart-item__remove")) { return }

      event.preventDefault()

      fn(targetEvent.dataset.itemId)
  })
}


function removeStockLevelClasses(el) {
  Array.from(el.classList).
    filter((s) => s.startsWith("size-container__entry--level-")).
    forEach((name) => el.classList.remove(name))
}

export default dom