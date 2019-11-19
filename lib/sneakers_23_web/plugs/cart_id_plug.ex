defmodule Sneakers23Web.CartIdPlug do
  import Plug.Conn

  alias Sneakers23.Checkout

  def init(_), do: []

  def call(conn, _opts) do
    {:ok, conn, cart_id} = get_cart_id(conn)
    assign(conn, :cart_id, cart_id)
  end

  defp get_cart_id(conn) do
    case get_session(conn, :cart_id) do
      nil ->
        cart_id = Checkout.generate_cart_id()
        conn = put_session_cart_id(conn, cart_id)
        {:ok, conn, cart_id}
      cart_id ->
        {:ok, conn, cart_id}
    end
  end

  defp put_session_cart_id(conn, cart_id) do
    put_session(conn, :cart_id, cart_id)
  end
end
