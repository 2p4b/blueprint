defmodule Blueprint.MixProject do
    use Mix.Project

    def project do
        [
            app: :blueprint,
            version: "0.1.0",
            elixir: "~> 1.14",
            start_permanent: Mix.env() == :prod,
            consolidate_protocols: Mix.env() != :test,
            deps: deps(),
            name: "Blueprint",
            source_url: "https://github.com/2p4b/blueprint"
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
            {:mix_test_watch, "~>1.0", only: :dev, runtime: false},
            {:ex_doc, "~> 0.19", only: :dev, runtime: false},
            {:timex, "~> 3.0"},
            {:uuid, "~> 1.1"}
        ]
    end

    
    defp description() do
        "Blueprint is a library for creating structs with type checking"
    end

    defp package() do
      [
          # This option is only needed when you don't want to use the OTP application name
          name: "blueprint",
          # These are the default files included in the package
          files: ~w(lib mix.exs README.md),
          maintainers: ["Che Mfoncho"],
          licenses: ["MIT"],
          links: %{"GitHub" => "https://github.com/2p4b/blueprint"}
      ]
    end
end
