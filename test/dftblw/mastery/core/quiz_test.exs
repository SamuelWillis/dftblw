defmodule DFTBLW.Mastery.Core.QuizTest do
  use ExUnit.Case, async: true

  alias DFTBLW.Mastery.Core.Quiz
  alias DFTBLW.Mastery.Core.Question
  alias DFTBLW.Mastery.Core.Response
  alias DFTBLW.Mastery.Core.Template

  @quiz Quiz.new(title: "Additon Test", mastery: 2)

  describe "new/1" do
    test "builds a new quiz" do
      assert %Quiz{} = @quiz
    end
  end

  describe "add_template/2" do
    test "adds a new template to the quiz" do
      assert %Quiz{} = quiz = quiz_with_template()

      assert %{addition: [%Template{}]} = quiz.templates
    end
  end

  describe "select_question/1" do
    test "returns quiz for no templates" do
      assert @quiz == Quiz.select_question(@quiz)
    end

    test "returns quiz with current question" do
      quiz = quiz_with_template()
      assert %Quiz{} = quiz = Quiz.select_question(quiz)

      assert %Question{} = quiz.current_question

      # Only one template so used templates will be empty
      assert [] = quiz.used
    end
  end

  describe "answer_question/2" do
    test "answers question" do
      quiz = quiz_with_template() |> Quiz.select_question()
      response = Response.new(quiz, "test@example.com", "3")

      assert %Quiz{} = quiz = Quiz.answer_question(quiz, response)

      assert quiz.last_response == response
    end
  end

  defp quiz_with_template do
    template_generator = %{left: [1, 2], right: [1, 2]}

    template_checker = fn sub, answer ->
      sub[:left] + sub[:right] == String.to_integer(answer)
    end

    Quiz.add_template(@quiz,
      name: :single_digit_addition,
      category: :addition,
      instructions: "Add the two numbers",
      raw: "<%= @left %> + <%= @right %>",
      generators: template_generator,
      checker: template_checker
    )
  end
end
