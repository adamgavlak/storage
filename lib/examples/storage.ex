defmodule Examples.Storage do
  use Storage.Object, directory: "static/data", adapter: Storage.Adapters.Local
end
