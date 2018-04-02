defmodule Storage do
  @moduledoc """
  Documentation for Storage.
  """

  @adapter Application.get_env(:storage, :adapter, Storage.Adapters.Local)
  @root Application.get_env(:storage, :root, "priv/files")

  @doc """

  """
  def build_file(source_path, opts \\ []) do
    source_filename = Path.basename(source_path)

    # Extract options
    filename = Keyword.get(opts, :filename, source_filename)
    scope = Keyword.get(opts, :scope, "")

    # Convert scope to string
    scope = convert_scope(scope)

    # Add extension if it's not in the new filename
    filename =
      cond do
        String.contains?(filename, ".") -> filename
        true -> "#{filename}#{Path.extname(source_filename)}"
      end

    path = Path.join([@root, scope, filename])

    metadata =
      source_path
      |> File.lstat!()
      |> Map.take([:ctime, :mtime, :size])

    %Storage.File{
      filename: filename,
      path: path,
      extension: Path.extname(path) |> String.replace_leading(".", ""),
      metadata: metadata,
      content_type: MIME.from_path(source_path)
    }
  end

  def convert_scope(scope) do
    cond do
      is_list(scope) ->
        scope
        |> Enum.map(fn item -> if is_list(item), do: convert_scope(item), else: to_string(item) end)
        |> Path.join()
      true -> to_string(scope)
    end
  end

  def put(source_path, opts \\ []) do
    adapter = Keyword.get(opts, :adapter, @adapter)

    build_file(source_path, opts)
    |> adapter.put(source_path)
  end

  def url(path, opts \\ []) do
    adapter = Keyword.get(opts, :adapter, @adapter)
    adapter.url(path)
  end

  def delete(path, opts \\ []) do
    adapter = Keyword.get(opts, :adapter, @adapter)
    adapter.delete(path)
  end
end
