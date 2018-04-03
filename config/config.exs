use Mix.Config

config :storage,
  adapter: Storage.Adapters.Local,
  root: "priv/files",
  host: [
    url: "http://localhost:4000",
    from: "/static"
  ]
