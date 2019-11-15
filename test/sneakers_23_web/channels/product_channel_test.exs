defmodule Sneakers23Web.ProductChannelTest do
  use Sneakers23Web.ChannelCase, async: true

  alias Sneakers23Web.{Endpoint, ProductChannel}
  alias Sneakers23.Inventory.CompleteProduct

  setup _ do
    {inventory, _data}  = Test.Factory.InventoryFactory.complete_products()
    product = %{items: [item]} = CompleteProduct.get_complete_products(inventory) |> List.first

    topic = "product:#{product.id}"
    Endpoint.subscribe(topic)

    {:ok, %{product: product, item: item}}

  end

  describe "notify_product_released/1" do
    test "the size selector for the product is broadcast", %{product: product} do
      ProductChannel.notify_product_released(product)

      assert_broadcast "released", %{size_html: html}
      assert html =~ "size-container__entry"
      Enum.each(product.items, fn item ->
        assert html =~ ~s(value="#{item.id}")
      end)
    end
  end

  describe "notify_product_stock_changed/1" do
    test "same stock not sent a broadcast", %{item: item} do
      data = ProductChannel.notify_item_stock_change(
        previous_item: item,
        current_item: item
      )

      assert data == {:ok, :no_change}

      refute_broadcast "stock_change", _
    end

    test "different stock should be sent as a broadcast", %{item: item} do
      new_item = Map.put(item, :available_count, 0)
      data = ProductChannel.notify_item_stock_change(
        previous_item: item,
        current_item: new_item
      )

      assert data == {:ok, :broadcast}

      payload_expected = %{item_id: item.id, product_id: item.product_id, level: "out"}
      assert_broadcast "stock_change", ^payload_expected
    end
  end
end