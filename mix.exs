defmodule PlugJwt.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_jwt,
     version: "0.5.0",
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
      {:joken, "~> 0.10"},
      {:plug, ">= 0.7.0"},
      {:cowboy, "~> 1.0.0"},
      {:jsx, "~> 2.1.1",  only: :test}
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
