defmodule DFTBLW.Mastery.Core.ResponseTest do
  use ExUnit.Case, async: true
  use QuizBuilders

  alias DFTBLW.Mastery.Core.Quiz
  alias DFTBLW.Mastery.Core.Response

  @user_email "test@example.com"

  describe "Response checks answers" do
    setup [:correct_response, :incorrect_response]

    test "building response checks answers", %{
      correct_response: correct_response,
      incorrect_response: incorrect_response
    } do
      assert correct_response.correct
      refute incorrect_response.correct
    end

    test "timestamp is added at build time", %{correct_response: correct_response} do
      assert %DateTime{} = correct_response.timestamp

      assert correct_response.timestamp < DateTime.utc_now()
    end
  end

  defp correct_response(_context) do
    quiz = quiz()
    %{correct_response: build_response(quiz, "3")}
  end

  defp incorrect_response(_context) do
    quiz = quiz()
    %{incorrect_response: build_response(quiz, "2")}
  end

  defp quiz do
    fields = template_fields(generators: %{left: [1], right: [2]})

    build_quiz()
    |> Quiz.add_template(fields)
    |> Quiz.select_question()
  end

  defp build_response(quiz, answer) do
    Response.new(quiz, @user_email, answer)
  end
end
