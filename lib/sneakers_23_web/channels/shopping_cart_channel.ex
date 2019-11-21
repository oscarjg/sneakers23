defmodule Sneakers23Web.ShoppingCartChannel do
  use Phoenix.Channel
  import Sneakers23Web.CartView, only: [cart_to_map: 1]

  alias Sneakers23.Checkout

  def join("cart:" <> _cart_id, params, socket) do
    socket = assign(socket, :cart, get_cart(params))
    send(self(), :send_cart)

    {:ok, socket}
  end

  def handle_in("add_item", %{"item_id" => id}, socket = %{assigns: %{cart: cart}}) do
    case Checkout.add_item_to_cart(cart, String.to_integer(id)) do
      {:ok, new_cart} ->
        broadcast_cart(new_cart, socket, added: [id])
        socket = assign(socket, :cart, new_cart)
        {:reply, {:ok, cart_to_map(new_cart)}, socket}
      {:error, error} ->
        {:reply, {:error, %{error: error}}, socket}
    end
  end

  def handle_in("remove_item", %{"item_id" => id}, socket = %{assigns: %{cart: cart}}) do
    case Checkout.remove_item_from_cart(cart, String.to_integer(id)) do
      {:ok, new_cart} ->
        broadcast_cart(new_cart, socket, removed: [id])
        socket = assign(socket, :cart, new_cart)
        {:reply, {:ok, cart_to_map(new_cart)}, socket}
      {:error, error} ->
        {:reply, {:error, %{error: error}}, socket}
    end
  end

  @spec handle_info(:send_cart, Phoenix.Socket.t()) :: {:noreply, Phoenix.Socket.t()}
  def handle_info(:send_cart, socket = %{assigns: %{cart: cart}}) do
    push(socket, "cart", cart_to_map(cart))
    {:noreply, socket}
  end

  intercept ["cart_updated"]
  @spec handle_out(<<_::96>>, map, Phoenix.Socket.t()) :: {:noreply, Phoenix.Socket.t()}
  def handle_out("cart_updated", params, socket) do
    cart = get_cart(params)
    socket = assign(socket, :cart, cart)
    push(socket, "cart", cart_to_map(cart))
    {:noreply, socket}
  end

  defp broadcast_cart(cart, socket, opts) do
    {:ok, serialized} = Checkout.export_cart(cart)

    broadcast_from(socket, "cart_updated", %{
      "serialized" => serialized,
      "added" => Keyword.get(opts, :added, []),
      "removed" => Keyword.get(opts, :removed, [])
    })
  end

  defp get_cart(params) do
    params
    |> Map.get("serialized", nil)
    |> Checkout.restore_cart()
  end
end
