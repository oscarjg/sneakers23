defmodule Sneakers23.Checkout.ShoppingCart do
  defstruct items: []

  @base Sneakers23Web.Endpoint
  @salt "shopping cart serialization"
  @max_age 86400 * 7

  def new(), do: %__MODULE__{}

  @spec add_item(any, any) ::
          {:error, :duplicated | :invalid_params} | {:ok, %{items: nonempty_maybe_improper_list}}
  def add_item(cart = %{items: items} , id) when is_integer(id) do
    if (id in items) do
      {:error, :duplicated}
    else
      {:ok, %{cart | items: [id | items]}}
    end
  end
  def add_item(_cart , _non_integer), do: {:error, :invalid_params}

  def remove_item(cart = %{items: items} , id) when is_integer(id) do
    if (id in items) do
      {:ok, %{cart | items: List.delete(items, id)}}
    else
      {:error, :not_found}
    end
  end
  def remove_item(_cart , _non_integer), do: {:error, :invalid_params}

  def item_ids(%{items: items}), do: items

  def serialize(cart = %__MODULE__{}, opts \\ []) do
    max_age = Keyword.get(opts, :max_age, @max_age)
    {:ok, Phoenix.Token.sign(@base, @salt, cart, max_age: max_age)}
  end

  def deserialize(serialized_data, opts \\ []) do
    max_age = Keyword.get(opts, :max_age, @max_age)

    case Phoenix.Token.verify(@base, @salt, serialized_data, max_age: max_age) do
      {:ok, data} ->
        items = Map.get(data, :items, [])
        {:ok, %__MODULE__{items: items}}
      error_data = {:error, _error} ->
        error_data
    end
  end
end
