defmodule Hike.MixProject do
  use Mix.Project
  @source_url "https://github.com/sharmavineett/hike"
  @version "0.1.0"

  def project do
    [
      app: :hike,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "The `Hike` module provides an implementation of the elevated data types.",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.27", only: :dev, runtime: false, test: "test"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      maintainers: ["Sharma Vineet"],
      files: ~w(CHANGELOG.md lib LICENSE mix.exs README.md),
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
