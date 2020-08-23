defmodule BencheeDsl.MixProject do
  use Mix.Project

  def project do
    [
      app: :benchee_dsl,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      consolidate_protocols: true,
      test_coverage: [tool: ExCoveralls],
      dialyzer: dialyzer(),
      preferred_cli_env: preferred_cli_env(),
      docs: [
        extras: ["README.md"],
        main: "readme"
      ],
      package: package(),
      name: "BencheeDsl",
      source_url: "https://github.com/hrzndhrn/benchee_dsl",
      description: "A DSL for benchee."
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

  defp dialyzer do
    [
      plt_add_apps: [:mix],
      plt_file: {:no_warn, "test/support/plts/dialyzer.plt"},
      flags: [:unmatched_returns]
    ]
  end

  defp deps do
    [
      {:benchee, ">= 0.99.0 and < 2.0.0"},
      {:benchee_markdown, "~> 0.1", only: [:dev, :test]},
      {:credo, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test, runtime: false},
      {:mox, "~> 0.5", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Marcus Kruse"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/hrzndhrn/benchee_dsl"
      }
    ]
  end
end
