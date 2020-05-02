defmodule BencheeDsl.MixProject do
  use Mix.Project

  def project do
    [
      app: :benchee_dsl,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {BencheeDsl.Application, []},
      env: env()
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      "coveralls.travis": :test
    ]
  end

  defp env do
    [
      benchee: BencheeDsl.Benchee,
      path: "bench"
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: [:dev, :test]},
      {:benchee_markdown, "~> 0.1", only: [:dev, :test]},
      {:credo, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test, runtime: false},
      {:mox, "~> 0.5", only: :test}
    ]
  end
end
