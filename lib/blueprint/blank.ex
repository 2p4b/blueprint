defprotocol Blueprint.Blank do
    @doc "Whether an item is blank"
    def blank?(value)
end

defimpl Blueprint.Blank, for: List do
    def blank?([]), do: true
    def blank?(_), do: false
end

defimpl Blueprint.Blank, for: Float do
    def blank?(_), do: false
end

defimpl Blueprint.Blank, for: Integer do
    def blank?(_), do: false
end

defimpl Blueprint.Blank, for: Tuple do
    def blank?({}), do: true
    def blank?(_), do: false
end

defimpl Blueprint.Blank, for: BitString do
    def blank?(""), do: true
    def blank?(_), do: false
end

defimpl Blueprint.Blank, for: Atom do
    def blank?(nil), do: true
    def blank?(false), do: true
    def blank?(_), do: false
end

defimpl Blueprint.Blank, for: Map do
    def blank?(map), do: map_size(map) == 0
end

defimpl Blueprint.Blank, for: [Date, DateTime, NaiveDateTime, Time] do
    def blank?(_), do: false
end

defimpl Blueprint.Blank, for: Any do
    def blank?(_), do: false
end
