defmodule Sneakers23.Checkout.ShoppingCartTest do
  use Sneakers23.DataCase, async: true

  alias Sneakers23.Checkout.ShoppingCart

  test "adding items to cart should work as expected" do
    cart = ShoppingCart.new()

    assert {:ok, cart} = ShoppingCart.add_item(cart, 1)
    assert [1] == cart.items
    assert {:error, :duplicated} = ShoppingCart.add_item(cart, 1)
    assert {:ok, cart} = ShoppingCart.add_item(cart, 2)
    assert [2, 1] == cart.items
  end

  test "remove item should work as expected" do
    {:ok, cart} = ShoppingCart.add_item(ShoppingCart.new(), 1)
    {:ok, cart} = ShoppingCart.add_item(cart, 2)

    {:ok, cart} = ShoppingCart.remove_item(cart, 2)
    assert [1] == cart.items
    {:error, :not_found} = ShoppingCart.remove_item(cart, 2)
    {:ok, cart} = ShoppingCart.remove_item(cart, 1)
    assert [] == cart.items
  end

  test "adding non intenger items to cart should return an error tuple" do
    cart = ShoppingCart.new()

    assert {:error, :invalid_params} = ShoppingCart.add_item(cart, "foo")
    assert {:error, :invalid_params} = ShoppingCart.add_item(cart, ["foo"])
    assert {:error, :invalid_params} = ShoppingCart.add_item(cart, %{"foo" => "bar"})
    assert {:error, :invalid_params} = ShoppingCart.add_item([], 1)
  end

  test "removing non intenger items to cart should return an error tuple" do
    cart = ShoppingCart.new()

    assert {:error, :invalid_params} = ShoppingCart.remove_item(cart, "foo")
    assert {:error, :invalid_params} = ShoppingCart.remove_item(cart, ["foo"])
    assert {:error, :invalid_params} = ShoppingCart.remove_item(cart, %{"foo" => "bar"})
    assert {:error, :invalid_params} = ShoppingCart.remove_item([], 1)
  end

  test "item_ids/0" do
    cart = ShoppingCart.new()
    {:ok, cart} = ShoppingCart.add_item(cart, 1)
    {:ok, cart} = ShoppingCart.add_item(cart, 2)

    assert [2, 1] = ShoppingCart.item_ids(cart)
  end

  test "serialize/2 and deserialize/2" do
    cart = ShoppingCart.new()
    assert {:ok, serialized_data} = ShoppingCart.serialize(cart)
    assert is_binary(serialized_data)
    assert {:ok, %ShoppingCart{items: []}} = ShoppingCart.deserialize(serialized_data)

    {:ok, cart} = ShoppingCart.add_item(cart, 1)
    {:ok, cart} = ShoppingCart.add_item(cart, 2)
    assert {:ok, serialized_data} = ShoppingCart.serialize(cart)
    assert {:ok, %ShoppingCart{items: [2, 1]}} = ShoppingCart.deserialize(serialized_data)
  end

  test "deserialized expired token should return an error" do
    cart = ShoppingCart.new()
    opts = [max_age: 0.5]
    assert {:ok, serialized_data} = ShoppingCart.serialize(cart, opts)
    assert {:error, _} = ShoppingCart.deserialize("foo_token", opts)

    assert_expired_token_func = fn serialized_data, opts, callback ->
      case ShoppingCart.deserialize(serialized_data, opts) do
        {:error, _} -> true
        {:ok, _} -> callback.(serialized_data, opts, callback)
      end
    end

    assert assert_expired_token_func.(serialized_data, opts, assert_expired_token_func)
  end
end
