defmodule RecordTest do
    use Blueprint.Struct
    defstruct name: nil, identifier: nil

    validates(:name, presence: true)
end

defmodule BlueprintTest do
    use Blueprint.Typed

    @name_format ~r/(^[[:alpha:]][[:alnum:]]+$)/

    @data_blueprint %{
        user: UserTest,
        score: [number: [less_than: 4]],
    }

    blueprint do
        field :name, :string, length: [min: 4],  format: @name_format

        field :age,  :number, required: true, greater_than: 2

        field :data, :map, @data_blueprint

        field :user, :struct, struct: UserTest, presence: [if: [age: 4]]

        field :number, :number, greater_than: 4, absence: [if: [age: 4]]
    end

end

defmodule UserTest do
    use Blueprint.Struct
    defstruct username: nil, password: nil, password_confirmation: nil, age: nil

    validates(:username, presence: true, length: [min: 4], format: ~r/(^[[:alpha:]][[:alnum:]]+$)/)
    validates(:password, length: [min: 4], confirmation: true)
end

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
