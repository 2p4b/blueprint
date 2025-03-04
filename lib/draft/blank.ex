defprotocol Draft.Blank do
    @doc "Whether an item is blank"
    def blank?(value)
end

defimpl Draft.Blank, for: List do
    def blank?([]), do: true
    def blank?(_), do: false
end

defimpl Draft.Blank, for: Float do
    def blank?(_), do: false
end

defimpl Draft.Blank, for: Integer do
    def blank?(_), do: false
end

defimpl Draft.Blank, for: Tuple do
    def blank?({}), do: true
    def blank?(_), do: false
end

defimpl Draft.Blank, for: BitString do
    def blank?(""), do: true
    def blank?(_), do: false
end

defimpl Draft.Blank, for: Atom do
    def blank?(nil), do: true
    def blank?(false), do: true
    def blank?(_), do: false
end

defimpl Draft.Blank, for: Map do
    def blank?(map), do: map_size(map) == 0
end

defimpl Draft.Blank, for: [Date, DateTime, NaiveDateTime, Time] do
    def blank?(_), do: false
end

defimpl Draft.Blank, for: Any do
    def blank?(_), do: false
end
