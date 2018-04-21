defmodule Storage.Support do
  @moduledoc """
  Support module contains functions used in various modules.
  """

  @doc """
  Converts `scope` to path string.
  """
  @spec convert_scope(List.t | String.t) :: String.t
  def convert_scope(scope) do
    cond do
      is_list(scope) ->
        scope
        |> Enum.map(fn item ->
          if is_list(item), do: convert_scope(item), else: to_string(item)
        end)
        |> Path.join()

      true ->
        to_string(scope)
    end
  end
end
