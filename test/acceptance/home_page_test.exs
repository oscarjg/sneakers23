defmodule Acceptance.HomePageTest do
  use Sneakers23.DataCase, async: false
  use Hound.Helpers

  alias Sneakers23.{Inventory, Repo}

  @homepage "http://localhost:4002"

  setup do
    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Repo, self())
    Hound.start_session(metadata: metadata)

    {inventory, _data} = Test.Factory.InventoryFactory.complete_products()
    {:ok, _} = GenServer.call(Inventory, {:test_set_inventory, inventory})

    :ok
  end

  @tag acceptance: true
  test "the page updates when a product is released" do
    navigate_to(@homepage)

    [coming_soon, available] = find_all_elements(:css, ".product-listing")

    assert inner_text(coming_soon) =~ "coming soon..."
    assert inner_text(available) =~ "coming soon..."

    # Release the shoe
    {:ok, [_, product]} = Inventory.get_complete_products()
    Inventory.mark_product_released!(product.id)

    # The second shoe will have a size-container and no coming soon text
    assert inner_text(coming_soon) =~ "coming soon..."
    refute inner_text(available) =~ "coming soon..."

    refute inner_html(coming_soon) =~ "size-container"
    assert inner_html(available) =~ "size-container"
  end

  @tag acceptance: true
  test "the page update when the prodcut reduce inventory" do
    {:ok, [_, product]} = Inventory.get_complete_products()
    Inventory.mark_product_released!(product.id)
    [item_1, _] = product.items

    navigate_to(@homepage)

    assert [item_1_button] =
      find_all_elements(:css, ".size-container__entry[value='#{item_1.id}']")

    assert outer_html(item_1_button) =~ "size-container__entry--level-low"
    refute outer_html(item_1_button) =~ "size-container__entry--level-out"

    new_item = Map.put(item_1, :available_count, 0)

    opts = [
      previous_item: item_1,
      current_item: new_item
    ]

    Sneakers23Web.notify_item_stock_change(opts)

    refute outer_html(item_1_button) =~ "size-container__entry--level-low"
    assert outer_html(item_1_button) =~ "size-container__entry--level-out"
  end
end
