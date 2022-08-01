defmodule Blueprint.Type.Datetime do
    use Timex

    @moduledoc """
    ## example

        iex> {:ok, _value} = Blueprint.Type.Datetime.cast("01-01-1900", [])

        iex> {:ok, _value} = Blueprint.Type.Datetime.cast("1900-01-01", [])

        iex> {:ok, _value} = Blueprint.Type.Datetime.cast("2016-02-29T22:25:00-06:00", [])

        iex> {:error, _reason} = Blueprint.Type.Datetime.cast("1900-91-91", [])
    """

    @iso_format ~r/^\d{4}-\d{2}-\d{2}T\d{1,2}:\d{1,2}:\d{1,2}-\d{1,2}:\d{1,2}$/

    @behaviour Blueprint.Type.Behaviour
    
    @impl Blueprint.Type.Behaviour
    def cast(nil, _opts) do
        {:ok, nil}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_number(value) do
        {:ok, Timex.from_unix(value)}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_binary(value) do
        dvalue = String.trim(value)
        cond do
            String.match?(dvalue, ~r/^\d{4}-\d{2}-\d{2}$/) ->
                Timex.parse(dvalue, "{YYYY}-{0M}-{D}")

            String.match?(dvalue, ~r/^\d{2}-\d{2}-\d{4}$/) ->
                Timex.parse(dvalue, "{D}-{0M}-{YYYY}")

            String.match?(dvalue, @iso_format) ->
                Timex.parse(dvalue, "{ISO:Extended}")

            true ->
                {:error, ["invalid datetime"]}
        end
    end

    @impl Blueprint.Type.Behaviour
    def cast(%Date{}=value, _opts) do
        {:ok, value}
    end

    @impl Blueprint.Type.Behaviour
    def cast(%DateTime{}=value, _opts) do
        {:ok, value}
    end

    @impl Blueprint.Type.Behaviour
    def cast(_value, _opts) do
        {:error, ["invalid datetime"]}
    end

    @impl Blueprint.Type.Behaviour
    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end


