defmodule DocTest do
    use ExUnit.Case
    # Main
    doctest Blueprint
    doctest Blueprint.Validator
    # Validator Utilities
    doctest Blueprint.Validator.ErrorMessage
    doctest Blueprint.Validator.Skipping
    # Built-in Validators
    doctest Blueprint.Validators.Absence
    doctest Blueprint.Validators.Acceptance
    doctest Blueprint.Validators.By
    doctest Blueprint.Validators.Confirmation
    doctest Blueprint.Validators.Exclusion
    doctest Blueprint.Validators.Format
    doctest Blueprint.Validators.Inclusion
    doctest Blueprint.Validators.Length
    doctest Blueprint.Validators.Number
    doctest Blueprint.Validators.Presence
    doctest Blueprint.Validators.Required
    doctest Blueprint.Validators.Uuid
    # Built-in ErrorRenderers
    doctest Blueprint.ErrorRenderers.EEx
    doctest Blueprint.ErrorRenderers.Parameterized
end
