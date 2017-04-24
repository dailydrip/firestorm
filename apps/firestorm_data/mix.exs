defmodule FirestormData.Mixfile do
  use Mix.Project

  def project do
    [
      app: :firestorm_data,
      version: "0.8.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [
        :logger
      ],
      mod: {FirestormData.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:ecto, "~> 2.1.2"},
      {:postgrex, ">= 0.0.0"},
      {:arbor, "~> 1.0.3"},
      {:ecto_autoslug_field, "~> 0.2"},
      {:gen_stage, "~> 0.11"},

      {:credo, "~> 0.7.3", only: [:dev, :test]},
    ]
  end

  defp aliases do
    [
      "test": ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"],
      "db:setup": ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "run priv/repo/seeds.exs"]
    ]
  end
end
