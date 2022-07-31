defmodule TestValidatorSourceByStructure.Criteria do
    def validate(_value, _options) do
    end
end

defmodule TestValidatorSourceByFunctionResult do
    def validate(_value, _options) do
    end
end

defmodule TestValidatorSourceByFunction do
    def validator(_name) do
    # always; stub
        TestValidatorSourceByFunctionResult
    end
end

defmodule TestValidatorSourceByFunction.Criteria do
  # Should be ignored
end

ExUnit.start()
