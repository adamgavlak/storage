defmodule Storage.Adapters.Local do
  @moduledoc """
  The `Local` adapter is used to store files locally in filesystem.

  ## Configuration

      config :storage, Storage.Adapters.Local
        root: "priv/files",
        host: [
          url: "http://localhost:4000",
          from: "/static"
        ]

  * `root:` defines where all the files will be placed in file system
  * `host:` data used in URL generation
      * `url:` is the url that will be prepended
      * `from:` is path in `root:` where all publicly served files are (e.g. you can configure this with `Plug.Static`)
  """

  @behaviour Storage.Adapter

  defp root, do: Application.get_env(:storage, Storage.Adapters.Local)[:root]
  defp host, do: Application.fetch_env!(:storage, Storage.Adapters.Local)[:host]

  def path(components) when is_list(components) do
    Path.join([root()] ++ components)
  end

  def put(%Storage.File{} = file, source) do
    file.path |> Path.dirname() |> File.mkdir_p!()
    File.copy!(source, file.path)

    file
  end

  def url(path) do
    if is_nil(host()[:url]) do
      raise "to generate url of a stored file, first define :host option in the :storage config"
    end

    from = normalized_from()

    path_from =
      case String.starts_with?(path, from) do
        true -> from
        _ -> Path.join(root(), from)
      end

    if String.starts_with?(path, path_from) do
      path = String.replace_leading(path, path_from, "")
      Path.join(host()[:url], path)
    else
      raise "URL can be generated only for files in `#{Path.join(root(), host()[:from])}`"
    end
  end

  defp normalized_from do
    String.replace(host()[:from], ~r(\/|\\), "")
  end

  def delete(path) do
    from = normalized_from()

    path =
      case String.starts_with?(path, from) do
        true -> Path.join(root(), path)
        _ -> path
      end

    File.rm!(path)
  end
end
