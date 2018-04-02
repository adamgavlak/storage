use Mix.Config

config :storage,
  root: "test_files",
  host: [
    url: "http://localhost:4000",
    from: "/static"
  ]
