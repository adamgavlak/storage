defmodule Storage.Adapter do
  @moduledoc """
  Behaviour used as a guide to implement adapters.

  TODO: How to implement an adapter
  """

  @type path() :: String.t
  @type file() :: Storage.File.t

  @doc """
  Generates path from list of `scope` and `filename`.

  Used only if adapter needs to append part of path to file destination path, where it will be stored.
  """
  @callback path(list(String.t)) :: String.t

  @doc """
  Stores the file using the `Storage.File` struct and source path of the file.
  """
  @callback put(file(), path()) :: file()

  @doc """
  Returns URL of the file from given `path`.
  """
  @callback url(path()) :: String.t

  @doc """
  Deletes the file in given `path`.
  """
  @callback delete(path()) :: :ok | {:error, String.t}
end
