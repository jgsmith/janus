defmodule Mensendi.Mixfile do
  use Mix.Project

  def project do
    [app: :mensendi,
     version: "0.0.1",
     name: "Mensendi",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/jgsmith/mensendi",
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.detail": :test,
       "coveralls.post": :test,
       "coveralls.html": :test
     ],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:gen_stage, :logger, :timex]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:benchfella, "~> 0.3.0", only: :dev},
      {:dogma, "~> 0.1", only: :dev},
      {:earmark, "~> 1.0", override: true, only: :dev},
      {:excheck, "~> 0.4.0", only: [:dev, :test] },
      {:excoveralls, "~> 0.5", only: [:dev, :test]},
      {:ex_doc, "~>0.12", only: :dev},
      {:gen_stage, "~> 0.4"},
      {:timex, "~> 3.0"},
      {:triq, github: "triqng/triq", only: [:dev, :test]}
    ]
  end
end
