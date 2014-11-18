defmodule PlugJwt.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_jwt,
     version: "0.3.2",
     elixir: "~> 1.0.0",
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger, :joken, :plug, :cowboy, :jsx]]
  end

  defp deps do
    [
      {:joken, "~> 0.6.0"},
      {:plug, ">= 0.7.0"},
      {:cowboy, "~> 1.0.0"},
      {:jsx, github: "talentdeficit/jsx", tag: "v2.1.1"}
    ]
  end

  defp description do
    """
    JWT Plug Middleware
    """
  end

  defp package do
    [
     files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     contributors: ["Bryan Joseph"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/bryanjos/plug_jwt"}
    ]
  end
end
