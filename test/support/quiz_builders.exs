defmodule QuizBuilders do
  alias DFTBLW.Mastery.Core.Template
  alias DFTBLW.Mastery.Core.Quiz
  alias DFTBLW.Mastery.Core.Question

  defmacro __using__(_options) do
    quote do
      alias DFTBLW.Mastery.Core.Template
      alias DFTBLW.Mastery.Core.Response
      alias DFTBLW.Mastery.Core.Quiz

      import QuizBuilders, only: :functions
    end
  end

  def build_quiz(quiz_overrides \\ []) do
    quiz_overrides |> quiz_fields() |> Quiz.new()
  end

  def build_quiz_with_two_templates(quiz_overrides \\ []) do
    quiz_overrides
    |> build_quiz()
    |> Quiz.add_template(template_fields())
    |> Quiz.add_template(double_digit_addition_template_fields())
  end

  def build_question(overrides \\ []) do
    overrides
    |> template_fields()
    |> Template.new()
    |> Question.new()
  end

  def quiz_fields(overrides) do
    Keyword.merge([title: "Simple Arithmetic"], overrides)
  end

  def template_fields(overrides \\ []) do
    Keyword.merge(base_template_fields(), overrides)
  end

  def double_digit_addition_template_fields() do
    template_fields(
      name: :double_digit_addition,
      generators: addition_generators(double_digits())
    )
  end

  def base_template_fields do
    [
      name: :single_digit_addition,
      category: :addition,
      instructions: "Add the numbers",
      raw: "<%= @left %> + <%= @right %>",
      generators: addition_generators(single_digits()),
      checker: &addition_checker/2
    ]
  end

  def addition_generators(left, right \\ nil), do: %{left: left, right: right || left}

  def addition_checker(substitutions, answer) do
    left = Keyword.fetch!(substitutions, :left)
    right = Keyword.fetch!(substitutions, :right)

    to_string(left + right) == String.trim(answer)
  end

  def double_digits(), do: Enum.to_list(10..99)
  def single_digits(), do: Enum.to_list(0..9)
end
