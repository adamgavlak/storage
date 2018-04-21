defmodule Storage.File do
  @moduledoc """
  Defines struct to save data about the file.

  The struct contains:

  * `filename` - name of the saved file
  * `path` - path to the saved file
  * `extension` - extension of the saved file (without dot)
  * `content_type` - MIME type
  * `metadata` - information about the file
    * `size` - size in bytes
    * `ctime` - creation time
    * `mtime` - modification time
  """
  defstruct filename: "", path: "", extension: "", content_type: "", metadata: %{}

  @doc """
  Creates and returns a new `Storage.File` struct from `path` with given options
  """
  @spec new(String.t, keyword) :: %Storage.File{filename: String.t, path: String.t, extension: String.t, content_type: String.t, metadata: %{size: integer, ctime: tuple,
  mtime: tuple}}
  def new(path, opts) do
    filename = Path.basename(path)

    # Extract options
    filename = Keyword.get(opts, :filename, filename)
    adapter = Keyword.fetch!(opts, :adapter)

    # Generate path
    dest_path = adapter.path([scope(opts), filename])

    %Storage.File{
      filename: filename,
      path: dest_path,
      extension: extension(path),
      metadata: metadata(path),
      content_type: MIME.from_path(path)
    }
  end

  defp scope(opts) do
    opts
    |> Keyword.get(:scope, "")
    |> Storage.Support.convert_scope()
  end

  defp metadata(path) do
    path
    |> File.lstat!()
    |> Map.take([:ctime, :mtime, :size])
  end

  defp extension(path) do
    path
    |> Path.extname()
    |> String.replace_leading(".", "")
  end
end
