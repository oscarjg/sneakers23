defmodule Sneakers23Web.ShoppingCartChannel do
  use Phoenix.Channel
  import Sneakers23Web.CartView, only: [cart_to_map: 1]

  alias Sneakers23.Checkout

  def join("cart:" <> _cart_id, params, socket) do
    socket = assign(socket, :cart, get_cart(params))
    send(self(), :send_cart)

    {:ok, socket}
  end

  def handle_info(:send_cart, socket = %{assigns: %{cart: cart}}) do
    push(socket, "cart", cart_to_map(cart))
    {:noreply, socket}
  end

  defp get_cart(params) do
    params
    |> Map.get(:serialized, nil)
    |> Checkout.restore_cart()
  end
end
