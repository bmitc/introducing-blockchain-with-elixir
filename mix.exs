defmodule IntroducingBlockchain.MixProject do
  use Mix.Project

  def project do
    [
      app: :introducing_blockchain,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_check, "~> 0.15.0", only: [:dev], runtime: false},
      {:ex_crypto, "~> 0.10.0"}
    ]
  end
end
