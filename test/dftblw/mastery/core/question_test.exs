defmodule DFTBLW.Mastery.Core.QuestionTest do
  use ExUnit.Case, async: true

  alias DFTBLW.Mastery.Core.Question
  alias DFTBLW.Mastery.Core.Template

  describe "new/1" do
    setup do
      template_generator = %{left: [1, 2], right: [1, 2]}

      template_checker = fn sub, answer ->
        sub[:left] + sub[:right] == String.to_integer(answer)
      end

      template =
        Template.new(
          name: :single_digit_addition,
          category: :addition,
          instructions: "Add the two numbers",
          raw: "<%= @left %> + <%= @right %>",
          generators: template_generator,
          checker: template_checker
        )

      {:ok, template: template}
    end

    test "builds a new question from a template", %{template: template} do
      assert %Question{} = question = Question.new(template)

      assert question.template == template

      Enum.each(template.generators, fn {generator_key, possible_substitutions} ->
        assert substitution = Keyword.fetch!(question.substitutions, generator_key)

        assert substitution in possible_substitutions
      end)
    end
  end
end
