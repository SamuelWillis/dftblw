defmodule DFTBLW.Mastery.Core.TemplateTest do
  use ExUnit.Case, async: true

  alias DFTBLW.Mastery.Core.Template
  @raw "<%= @left %> + <%= @right %>"

  describe "new/1" do
    test "builds template from fields" do
      template_generator = %{left: [1, 2], right: [1, 2]}

      template_checker = fn sub, answer ->
        sub[:left] + sub[:right] == String.to_integer(answer)
      end

      assert %Template{} =
               template =
               Template.new(
                 name: :single_digit_addition,
                 category: :addition,
                 instructions: "Add the two numbers",
                 raw: @raw,
                 generators: template_generator,
                 checker: template_checker
               )

      IO.inspect(template.generators)

      assert template.name == :single_digit_addition
      assert template.category == :addition
      assert template.instructions == "Add the two numbers"
      assert template.compiled == EEx.compile_string(@raw)
      assert template.generators == template_generator
      assert template.checker == template_checker
    end
  end
end
