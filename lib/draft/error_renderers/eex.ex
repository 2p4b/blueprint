defmodule Draft.ErrorRenderers.EEx do
    @moduledoc false

    @behaviour Draft.ErrorRenderer

    @doc """
    ## Examples

        iex> Draft.ErrorRenderers.EEx.message(nil, "default")
        "default"

        iex> Draft.ErrorRenderers.EEx.message([message: "override"], "default")
        "override"

        iex> Draft.ErrorRenderers.EEx.message([message: "Context #<%= value %>"], "default", value: 2)
        "Context #2"

    """
    def message(options, default, context \\ []) do
        message = Draft.ErrorRenderer.get_message(options, default)
        message |> EEx.eval_string(context)
    end
end
