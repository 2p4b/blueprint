defmodule Blueprint.Validator.UUID do

    use Blueprint.Validator

    @uuid_formats [:default, :hex, :urn]

    @formats [:any, :not_any] ++ @uuid_formats

    @urn_prefix "urn:uuid:"

    @message_fields [value: "Bad value", format: "The UUID format"]
    def validate(value, true), do: validate(value, format: :any)
    def validate(value, false), do: validate(value, format: :not_any)
    def validate(value, options) when options in @formats, do: validate(value, format: options)

    def validate(value, options) when is_list(options) do
        unless_skipping value, options do
            format = options[:format]

            case do_validate(value, format) do
                :ok  -> 
                    {:ok, value}

                {:error, reason} -> 
                    {:error, message(options, reason, value: value, format: format)}
            end
        end
    end

    defp do_validate(<<_::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>>, :default) do
        :ok
    end

    defp do_validate(<<_::256>>, :hex) do
        :ok
    end

    defp do_validate(<<@urn_prefix, _::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>>, :urn) do
        :ok
    end

    defp do_validate(_, format) when format in @uuid_formats do
        {:error, "must be a valid UUID string in #{format} format"}
    end

    defp do_validate(value, :any) do
        error = {:error, "must be a valid UUID string"}

        Enum.reduce_while(@uuid_formats, error, fn format, _ ->
            case do_validate(value, format) do
                :ok -> {:halt, :ok}
                _ -> {:cont, error}
            end
        end)
    end

    defp do_validate(value, :not_any) do
        case do_validate(value, :any) do
            :ok -> {:error, "must not be a valid UUID string"}
            _ -> :ok
        end
    end

    defp do_validate(_, format) do
        raise "Invalid value #{inspect(format)} for option :format"
    end

end
