defmodule Draft.MixProject do
    use Mix.Project

    @version "1.0.0"

    @source_url "https://github.com/2p4b/blueprint"

    def project do
        [
            app: :draft,
            version: @version,
            elixir: "~> 1.14",
            start_permanent: Mix.env() == :prod,
            consolidate_protocols: Mix.env() != :test,
            deps: deps(),
            docs: docs(),
            name: "Draft",
            package: package(),
            description: description(),
            source_url: @source_url 
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
        "Draft is a library for creating structs with type checking"
    end

    defp package() do
        [
            # This option is only needed when you don't want to use the OTP application name
            name: "draft",
            # These are the default files included in the package
            files: ~w(lib mix.exs README.md),
            maintainers: ["Che Mfoncho"],
            licenses: ["MIT"],
            links: %{"GitHub" => @source_url}
        ]
    end

    def docs() do
        [
            main: "readme",
            name: "Draft",
            source_ref: "v#{@version}",
            canonical: "http://hexdocs.pm/draft",
            source_url: @source_url,
            extras: ["README.md", "LICENSE"]
        ]
    end

end
