use Mix.Config

config :storage,
  adapter: Storage.Adapters.Local

import_config "#{Mix.env}.exs"
