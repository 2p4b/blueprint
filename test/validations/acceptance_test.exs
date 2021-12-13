defmodule AcceptanceTestRecord do
    use Blueprint.Struct

    blueprint do
        field :accepts_terms, :boolean, acceptance: true
    end

end

defmodule CustomAcceptanceTestRecord do
    use Blueprint.Struct

    blueprint do
        field :accepts_terms, :string, acceptance: [as: "yes"]
    end

end

defmodule AcceptanceTest do
    use ExUnit.Case

    @tag :acceptance
    test "keyword list, provided basic acceptance validation" do
        assert Blueprint.valid?([accepts_terms: true], accepts_terms: [acceptance: true])
        assert Blueprint.valid?([accepts_terms: "anything"], accepts_terms: [acceptance: true])
        assert !Blueprint.valid?([accepts_terms: nil], accepts_terms: [acceptance: true])
    end

    @tag :acceptance
    test "keyword list, included presence validation" do
        assert Blueprint.valid?(accepts_terms: true, _rules: [accepts_terms: [acceptance: true]])
        assert Blueprint.valid?(accepts_terms: "anything", _rules: [accepts_terms: [acceptance: true]])
        assert !Blueprint.valid?(accepts_terms: false, _rules: [accepts_terms: [acceptance: true]])
    end

    @tag :acceptance
    test "keyword list, provided custom acceptance validation" do
        assert Blueprint.valid?([accepts_terms: "yes"], accepts_terms: [acceptance: [as: "yes"]])
        assert !Blueprint.valid?([accepts_terms: false], accepts_terms: [acceptance: [as: "yes"]])
        assert !Blueprint.valid?([accepts_terms: true], accepts_terms: [acceptance: [as: "yes"]])
    end

    @tag :acceptance
    test "keyword list, included custom validation" do
        assert Blueprint.valid?(accepts_terms: "yes", _rules: [accepts_terms: [acceptance: [as: "yes"]]])
        assert !Blueprint.valid?(accepts_terms: false, _rules: [accepts_terms: [acceptance: [as: "yes"]]])
        assert !Blueprint.valid?(accepts_terms: true, _rules: [accepts_terms: [acceptance: [as: "yes"]]])
    end

    @tag :acceptance
    test "record, included basic presence validation" do
        assert !Blueprint.valid?(%AcceptanceTestRecord{accepts_terms: "yes"})
        assert Blueprint.valid?(%AcceptanceTestRecord{accepts_terms: true})
    end

    @tag :acceptance
    test "record, included custom presence validation" do
        assert Blueprint.valid?(%CustomAcceptanceTestRecord{accepts_terms: "yes"})
        assert !Blueprint.valid?(%CustomAcceptanceTestRecord{accepts_terms: true})
        assert !Blueprint.valid?(%CustomAcceptanceTestRecord{accepts_terms: false})
    end
end
