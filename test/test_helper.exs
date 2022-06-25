defmodule RecordTest do
    use Blueprint.Struct
    
    blueprint do
        field :name, :string, presence: true
        field :identifier, :number, default: nil
    end

end

defmodule ValueStruct do
    use Blueprint.Struct
    
    blueprint do
        field :id,      :uuid,  default: nil
        field :value,   :value, presence: true
    end

end

defmodule DiceTest do
    use Blueprint.Struct
    
    blueprint do
        field :numbers, :list, of: :number
        field :users, :list, of: UserTest
        field :svalue, :value, presence: true
    end

end

defmodule UserTest do
    use Blueprint.Struct
    blueprint do
        field :username, :string, presence: true, length: [min: 4], format: ~r/(^[[:alpha:]][[:alnum:]]+$)/
        field :password, :string, length: [min: 4], confirmation: true

        field :password_confirmation, :string, required: true

        field :age, :number
    end
end

defmodule BlueprintTest do
    use Blueprint.Struct

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
