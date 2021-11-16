defmodule DFTBLW.Mastery.Core.QuestionTest do
  use ExUnit.Case, async: true
  use QuizBuilders

  alias DFTBLW.Mastery.Core.Question
  alias DFTBLW.Mastery.Core.Template

  test "building chooses substitutions" do
    question = build_question(generators: addition_generators([1], [2]))

    assert question.substitutions == [left: 1, right: 2]
  end

  test "function generators are called" do
    generators = addition_generators(fn -> 42 end, [0])

    assert %Question{substitutions: substitutions} = build_question(generators: generators)

    assert Keyword.fetch!(substitutions, :left) == generators.left.()
  end

  test "building creates asked question text" do
    question = build_question(generators: addition_generators([1], [2]))

    assert question.asked == "1 + 2"
  end

  test "a random choice is made from list generators" do
    generators = addition_generators(Enum.to_list(1..9), [0])

    assert eventually_match(generators, 1)
    assert eventually_match(generators, 9)
  end

  defp eventually_match(generators, answer) do
    Stream.repeatedly(fn ->
      %Question{substitutions: substitutions} = build_question(generators: generators)

      substitutions
    end)
    |> Enum.find(fn substitution ->
      Keyword.fetch!(substitution, :left) == answer
    end)
  end
end
