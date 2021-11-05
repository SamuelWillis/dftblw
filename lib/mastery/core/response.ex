defmodule DFTBLW.Mastery.Core.Response do
  @moduledoc """
  A user's answer to a question
  """

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
end
