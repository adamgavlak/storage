defmodule Storage.Object do
  @moduledoc """
  Use of this module helps with easy configuration to store, retrieve and delete similar files.

  ## Definition

  New file module can be created really easy:

      defmodule Photo do
        use Storage.Object,
          directory: "photos"
      end

  As a options you can specify keyword list:

  * `directory:` - a subdirectory within path of configuration variable `root:`, where files saved using this module will be stored
  * `adapter:` - if you would like to use different adapter for this object

  ## Functions

  After you `use Storage.Object` you will have access to these functions:

  * `store(source, scope \\\\ "")` - Source can be path or `Plug.Upload` struct
  * `url(filename, scope \\\\ "")` - Returns the url of file given file if it exists
  * `delete(filename, scope \\\\ "")` - Deletes the file in given scope

  `scope` can be a simple value (a number or a string), or a list of values

  ## Overridable functions
  There are also two overridable functions

  * `filename(%Storage.File{} = file, scope)` - this function returns the name of a file,
  which will be saved. It can be modified in any way using the data from `file`, `scope` or
  even randomly generate the file name.
  * `valid?(%Storage.File{} = file)` - this function returns true/false value and makes sure the
  `file` is valid. Extension, size, or other attributes can be used to determine if file is valid or not.

  Let's have a look at an example, where we override the functions above. We will generate random filename and check if the original file type is valid:

      defmodule Photo do
        use Storage.Object,
          directory: "photos"

        def filename(%Storage.File{} = file, scope) do
          Ecto.UUID.generate()
        end

        @allowed_extensions ~w(jpg jpeg png)
        def valid?(%Storage.File{} = file) do
          file.extension in @allowed_extensions and file.metadata.size < 2_000_000
        end
      end

  After definition we can use the module like this:

      iex> album = "some_album"
      iex> user = %{id: 1}
      iex> Photo.store("path/to/file", [user.id, album])

  Here we use user's ID and album as a scope and the file will be saved to
  `photos/1/some_album/`. Then we can retrieve URL or delete the file using
  file's name and the scope:

      iex> Photo.url("d72dfb2a-2ab9-4466-bf3b-cd059296026e.jpg", [user.id, album])
      "http://localhost:4000/photos/1/some_album/d72dfb2a-2ab9-4466-bf3b-cd059296026e.jpg"

  """

  defmacro __using__(opts \\ []) do
    adapter = Keyword.get(opts, :adapter, Storage.Adapters.Local)
    object_scope = Keyword.get(opts, :directory, "")

    quote bind_quoted: [adapter: adapter, object_scope: object_scope] do
      def store(source, scope \\ "")

      def store(%Plug.Upload{filename: filename, path: path}, scope) do
        file =
          path
          |> Storage.File.new([
            adapter: unquote(adapter),
            scope: [unquote(object_scope), scope],
            filename: filename
          ])

        store_object(path, scope, file)
      end

      def store(source_path, scope) do
        file =
          source_path
          |> Storage.File.new([
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

      defp build_path(filename, scope) do
        scope = Storage.Support.convert_scope(scope)
        Path.join([unquote(object_scope), scope, filename])
      end

      defp filename(file, _scope), do: file.filename
      defp valid?(_file), do: true

      defoverridable [filename: 2, valid?: 1]
    end
  end
end
