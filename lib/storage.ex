defmodule Storage do
  @moduledoc """
  The main module, which contains all the core functions for basic handling of files.

  This module has functions only for direct handling of the files, `Storage.Object` can
  be used to make it easier storing files of specific types.

  ## Configuration

  Here's an example configuration:

      config :storage,
        adapter: Storage.Adapters.Local

      config :storage, Storage.Adapters.Local
        root: "priv/files",
        host: [
          url: "http://localhost:4000",
          from: "/static"
        ]

  * `adapter:` key defines which adapter should be used when storing files. Storage ships only with `Storage.Adapters.Local`, if you want to use S3 or other adapter, you need to download approporiate package

  After configuring which adapter will be used, we have to configure the adapter itself. You can look at `Storage.Adapters.Local` documentation for details about the options.
  """

  defp adapter, do: Application.fetch_env!(:storage, :adapter)

  @doc """
  Stores the file from `path` with given options.

  The file will be stored in a path defined by `:root` environment variable (defaults to `/`) and `Storage.File` struct will be returned.

  ## Options

    * `:adapter` - overrides the adapter used in configuration
    * `:filename` - new file name (if the filename option doesn't include
    extension, `path` will be used to generate one)
    * `:scope` - directory (or list of directories) where to store the file

  ## Example

      iex> Storage.put("./some_image.jpg", scope: ["users", 1], filename: "some_name")
      %Storage.File{
        content_type: "image/jpeg",
        extension: "jpg",
        filename: "some_name.jpg",
        metadata: %{
          ctime: {{2018, 4, 3}, {6, 47, 14}},
          mtime: {{2018, 4, 3}, {6, 47, 14}},
          size: 14041
        },
        path: "priv/files/users/1/some_name.jpg"
      }

  """
  @type source() :: String.t
  @spec put(source, keyword) :: Storage.File.t
  def put(path, opts \\ []) do
    adapter = Keyword.get(opts, :adapter, adapter())

    Storage.File.new(path, Keyword.put(opts, :adapter, adapter))
    |> adapter.put(path)
  end

  @doc """
  Generates URL for file in given `path`.

  Adapter from configuration can be overriden by passing an `:adapter` option. Some adapters will need `:host` environment variable to generate correct URL.
  """
  @spec url(String.t, keyword) :: String.t
  def url(path, opts \\ []) do
    adapter = Keyword.get(opts, :adapter, adapter())
    adapter.url(path)
  end

  @doc """
  Deletes the file in given `path`.

  Adapter from configuration can be overriden by using an `:adapter` option.
  """
  @spec delete(String.t, keyword) :: String.t
  def delete(path, opts \\ []) do
    adapter = Keyword.get(opts, :adapter, adapter())
    adapter.delete(path)
  end
end
