defmodule Storage.Adapters.Local do
  @behaviour Storage.Adapter

  @root Application.get_env(:storage, :root)
  @host Application.get_env(:storage, :host)

  def put(%Storage.File{} = file, source) do
    file.path |> Path.dirname |> File.mkdir_p!()
    File.copy!(source, file.path)

    file
  end

  def exists?(path) do
    File.exists?(path)
  end

  def url(path) do
    if is_nil(@host[:url]) do
      raise "to generate url of a stored file, first define :host option in the :storage config"
    end

    from = normalized_from()

    path_from =
      case String.starts_with?(path, from) do
        true -> from
        _ -> Path.join(@root, from)
      end

    if String.starts_with?(path, path_from) do
      path = String.replace_leading(path, path_from, "")
      Path.join(@host[:url], path)
    else
      raise "URL can be generated only for files in `#{Path.join(@root, @host[:from])}`"
    end
  end

  def normalized_from do
    String.replace(@host[:from], ~r(\/|\\), "")
  end

  def delete(path) do
    from = normalized_from()

    path =
      case String.starts_with?(path, from) do
        true -> Path.join(@root, path)
        _ -> path
      end

    File.rm!(path)
  end
end
