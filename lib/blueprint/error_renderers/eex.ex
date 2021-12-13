defmodule Blueprint.ErrorRenderers.EEx do
    @moduledoc false

    @behaviour Blueprint.ErrorRenderer

    @doc """
    ## Examples

        iex> Blueprint.ErrorRenderers.EEx.message(nil, "default")
        "default"

        iex> Blueprint.ErrorRenderers.EEx.message([message: "override"], "default")
        "override"

        iex> Blueprint.ErrorRenderers.EEx.message([message: "Context #<%= value %>"], "default", value: 2)
        "Context #2"

    """
    def message(options, default, context \\ []) do
        message = Blueprint.ErrorRenderer.get_message(options, default)
        message |> EEx.eval_string(context)
    end
end
