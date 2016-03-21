defmodule ComoVa.Mixfile do
    use Mix.Project

    def project do
        [app: :como_va,
        version: "0.0.1",
        elixir: "~> 1.0",
        escript: escript,
        deps: deps]
    end

    defp escript do
        [main_module: ComoVa]
    end

    defp deps do
    []
    end
end
