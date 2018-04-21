defmodule Storage.MixProject do
  use Mix.Project

  def project do
    [
      app: :storage,
      version: "0.2.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      description: "Simple file management library",
      package: package(),
      docs: docs()
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

  defp docs do
    [
      main: "Storage",
      logo: "logo.png",
      source_url: "https://github.com/gavlak/storage",
      groups_for_modules: [
        "Storing files": [
          Storage,
          Storage.Object
        ],

        "Adapters": [
          Storage.Adapter,
          Storage.Adapters.Local
        ],

        "Support": [
          Storage.File,
          Storage.Support
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.18.3", only: :dev, runtime: false},
      {:plug, "~> 1.0"}
    ]
  end
end
