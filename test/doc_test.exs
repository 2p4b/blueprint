defmodule DocTest do
    use ExUnit.Case

    @tag :string
    doctest Blueprint.Types.String

    @tag :datetime
    doctest Blueprint.Types.Datetime

    @tag :exclusion
    doctest Blueprint.Validators.Exclusion

    @tag :format
    doctest Blueprint.Validators.Format

    # Main
    #doctest Blueprint
    #doctest Blueprint.Validator
    # Validator Utilities
    #doctest Blueprint.Validator.ErrorMessage
    #doctest Blueprint.Validator.Skipping
    # Built-in Validators
    #doctest Blueprint.Validators.Absence
    #doctest Blueprint.Validators.Acceptance
    #doctest Blueprint.Validators.By
    #doctest Blueprint.Validators.Confirmation
    #doctest Blueprint.Validators.Inclusion
    #doctest Blueprint.Validators.Length
    #doctest Blueprint.Validators.Number
    #doctest Blueprint.Validators.Presence
    #doctest Blueprint.Validators.Uuid
    # Built-in ErrorRenderers
    #doctest Blueprint.ErrorRenderers.EEx
    #doctest Blueprint.ErrorRenderers.Parameterized
end
