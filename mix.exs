defmodule Storage.MixProject do
  use Mix.Project

  def project do
    [
      app: :storage,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      description: "Simple file management library",
      package: package(),
      source_url: "https://github.com/gavlak/storage"
    ]
  end

  defp package do
    [
      maintainers: ["Adam Gavlák"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/gavlak/storage"},
      files: ~w(mix.exs README.md lib)
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:plug, "~> 1.0"}
    ]
  end
end
