defmodule MyMap.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_map,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:benchee_dsl, path: "../..", only: :dev}
    ]
  end
end