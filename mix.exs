defmodule Blueprint.MixProject do
    use Mix.Project

    def project do
        [
            app: :blueprint,
            version: "0.1.0",
            build_path: "../../_build",
            config_path: "../../config/config.exs",
            deps_path: "../../deps",
            lockfile: "../../mix.lock",
            elixir: "~> 1.12",
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
            {:ex_doc, "~> 0.19", only: :dev, runtime: false}
        ]
    end
end
