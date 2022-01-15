defmodule DFTBLW.Mastery.Core.Response do
  @moduledoc """
  A user's answer to a question
  """

  alias DFTBLW.Mastery.Core.Quiz

  defstruct ~w[quiz_title template_name to email answer correct timestamp]a

  @type t :: %__MODULE__{
          quiz_title: binary(),
          template_name: atom(),
          to: binary(),
          email: binary(),
          answer: binary(),
          correct: boolean(),
          timestamp: DateTime.t()
        }

  @doc """
  Create a new Response.
  """
  @spec new(Quiz.t(), email :: binary(), answer :: binary()) :: t()
  def new(quiz, email, answer) do
    question = quiz.current_question
    template = question.template

    %__MODULE__{
      quiz_title: quiz.title,
      template_name: template.name,
      to: question.asked,
      email: email,
      answer: answer,
      correct: template.checker.(question.substitutions, answer),
      timestamp: DateTime.utc_now()
    }
  end
end
