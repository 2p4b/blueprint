defmodule Draft.ErrorRenderers.Parameterized do
    @moduledoc false

    @behaviour Draft.ErrorRenderer

    @doc """

    ## Examples

        iex> Draft.ErrorRenderers.Parameterized.message(nil, "default")
        [message: "default", context: []]

        iex> Draft.ErrorRenderers.Parameterized.message([message: "override"], "default")
        [message: "override", context: []]

        iex> Draft.ErrorRenderers.Parameterized.message([message: "Context #<%= value %>"], "default", value: 2)
        [message: "Context #<%= value %>", context: [value: 2]]

    """
    def message(options, default, context \\ []) do
        message = Draft.ErrorRenderer.get_message(options, default)
        [message: message, context: context]
    end
end
