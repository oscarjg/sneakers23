/***
 * Excerpted from "Real-Time Phoenix",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/sbsockets for more book information.
***/
import css from "../css/app.css"
import { productSocket } from "./socket"
import dom from "./dom"

const productsIds = dom.getProductIds()

if (productsIds.length > 0) {
    productSocket.connect()
    productsIds.forEach((id) => { setupProductChannel(productSocket, id) })
}

function setupProductChannel(socket, productId) {
    const channel = socket.channel(`product:${productId}`)
    channel.join()
        .receive("error", () => {
            console.log("channel join failed")
        })

    channel.on("released", ({size_html}) => {
        dom.replaceProductComingSoon(productId, size_html)
    })

    channel.on('stock_change', ({ product_id, item_id, level }) => {
        dom.updateItemLevel(item_id, level)
    })
}
