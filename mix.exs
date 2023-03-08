defmodule Blueprint.MixProject do
    use Mix.Project

    def project do
        [
            app: :blueprint,
            version: "0.1.0",
            elixir: "~> 1.14",
            start_permanent: Mix.env() == :prod,
            consolidate_protocols: Mix.env() != :test,
            deps: deps()
        ]
    end

    # Run "mix help compile.app" to learn about applications.
    def application do
        [
            extra_applications: [:logger, :eex]
        ]
    end

    # Run "mix help deps" to learn about dependencies.
    defp deps do
        [
            {:ex_doc, "~> 0.19", only: :dev, runtime: false},
            {:timex, "~> 3.0"},
            {:uuid, "~> 1.1"}
        ]
    end
end
