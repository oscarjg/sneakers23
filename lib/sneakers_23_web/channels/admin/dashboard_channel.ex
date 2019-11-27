defmodule Sneakers23Web.Admin.DashboardChannel do
  use Phoenix.Channel

  @spec join(<<_::144>>, any, any) :: {:ok, any}
  def join("admin:cart_tracker", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Sneakers23.CartTracker.all_carts())
    {:noreply, socket}
  end
end
