use Mix.Config

config :storage,
  root: "priv/files",
  host: [
    url: "http://localhost:4000",
    from: "/static"
  ]
