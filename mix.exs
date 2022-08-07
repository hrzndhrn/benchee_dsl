defmodule BencheeDsl.MixProject do
  use Mix.Project

  @source_url "https://github.com/hrzndhrn/benchee_dsl"

  def project do
    [
      app: :benchee_dsl,
      version: "0.3.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      consolidate_protocols: true,
      test_coverage: [tool: ExCoveralls],
      dialyzer: dialyzer(),
      aliases: aliases(),
      preferred_cli_env: preferred_cli_env(),
      docs: [
        extras: ["README.md"],
        main: "readme"
      ],
      package: package(),
      name: "BencheeDsl",
      source_url: @source_url,
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
      carp: :test,
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
      # {:benchee, path: "../../forks/benchee"},
      # dev/test
      {:benchee_markdown, "~> 0.2", only: [:dev, :test]},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test, runtime: false},
      {:mox, "~> 1.0", only: :test}
    ] ++ recode()
  end

  defp recode() do
    case Version.match?(System.version(), "~> 1.12") do
      true -> [{:recode, "~> 0.1", only: [:dev, :test]}]
      false -> []
    end
  end

  defp aliases do
    [
      carp: "test --seed 0 --max-failures 1"
    ]
  end

  defp package do
    [
      maintainers: ["Marcus Kruse"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
