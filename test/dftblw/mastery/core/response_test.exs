defmodule DFTBLW.Mastery.Core.ResponseTest do
  use ExUnit.Case, async: true

  alias DFTBLW.Mastery.Core.Quiz
  alias DFTBLW.Mastery.Core.Response

  @email "test@example.com"

  describe "new/3" do
    test "builds new response to current question" do
      quiz = build_quiz()

      assert %Response{} = response = Response.new(quiz, @email, "3")

      assert response.quiz_title == quiz.title
      assert response.template_name == quiz.current_question.template.name
      assert response.to == quiz.current_question.asked
      assert response.email == @email
      assert response.answer == "3"
      assert is_boolean(response.correct)
    end
  end

  defp build_quiz do
    template_generator = %{left: [1, 2], right: [1, 2]}

    template_checker = fn sub, answer ->
      sub[:left] + sub[:right] == String.to_integer(answer)
    end

    Quiz.new(title: "Additon Test", mastery: 2)
    |> Quiz.add_template(
      name: :single_digit_addition,
      category: :addition,
      instructions: "Add the two numbers",
      raw: "<%= @left %> + <%= @right %>",
      generators: template_generator,
      checker: template_checker
    )
    |> Quiz.select_question()
  end
end
