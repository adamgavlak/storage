defmodule Storage.Object do
  defmacro __using__(opts \\ []) do
    adapter = Keyword.get(opts, :adapter, Storage.Adapters.Local)
    object_scope = Keyword.get(opts, :dir, "")

    quote bind_quoted: [adapter: adapter, object_scope: object_scope] do
      def store(source, scope \\ "")

      def store(%Plug.Upload{filename: filename, path: path}, scope) do
        file =
          path
          |> Storage.build_file([
            adapter: unquote(adapter),
            scope: [unquote(object_scope), scope],
            filename: filename
          ])

        store_object(path, scope, file)
      end

      def store(source_path, scope) do
        file =
          source_path
          |> Storage.build_file([
            adapter: unquote(adapter),
            scope: [unquote(object_scope), scope]
          ])

        store_object(source_path, scope, file)
      end

      defp store_object(source, scope, file) do
        filename = filename(file, scope)

        file = replace_filename(file, filename)

        if valid?(file) do
          unquote(adapter).put(file, source)
        else
          {:error, :file_not_valid}
        end
      end

      defp replace_filename(file, new_filename) do
        path =
          file.path
          |> Path.split()
          |> List.replace_at(-1, new_filename)
          |> Path.join()

        file
        |> Map.put(:filename, new_filename)
        |> Map.put(:path, path)
      end

      def url(filename, scope \\ "") do
        path = build_path(filename, scope)
        unquote(adapter).url(path)
      end

      def delete(filename, scope \\ "") do
        path = build_path(filename, scope)
        unquote(adapter).delete(path)
      end

      def build_path(filename, scope) do
        scope = Storage.convert_scope(scope)
        Path.join([unquote(object_scope), scope, filename])
      end

      defp filename(file, _scope), do: file.filename
      defp valid?(_file), do: true

      defoverridable [filename: 2, valid?: 1]
    end
  end
end
