defmodule Blueprint.ErrorRenderers.Parameterized do
    @moduledoc false

    @behaviour Blueprint.ErrorRenderer

    @doc """

    ## Examples

        iex> Blueprint.ErrorRenderers.Parameterized.message(nil, "default")
        [message: "default", context: []]

        iex> Blueprint.ErrorRenderers.Parameterized.message([message: "override"], "default")
        [message: "override", context: []]

        iex> Blueprint.ErrorRenderers.Parameterized.message([message: "Context #<%= value %>"], "default", value: 2)
        [message: "Context #<%= value %>", context: [value: 2]]

    """
    def message(options, default, context \\ []) do
        message = Blueprint.ErrorRenderer.get_message(options, default)
        [message: message, context: context]
    end
end
