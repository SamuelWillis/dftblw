defmodule DFTBLW.Mastery.Core.Quiz do
  @moduledoc """
  A quiz a user goes through to prove their mastery.

  A quiz will ask questions until the user achieves mastery.

  Takes a set of templates organized by category and cycles through them.
  Once the user answers enough questions correctly in a row, we stop asking the
  question
  """

  alias DFTBLW.Mastery.Core.Question
  alias DFTBLW.Mastery.Core.Response
  alias DFTBLW.Mastery.Core.Template

  defstruct title: "",
            mastery: 3,
            current_question: nil,
            last_response: nil,
            templates: %{},
            used: [],
            mastered: [],
            record: %{}

  @type t :: %__MODULE__{
          title: binary(),
          mastery: integer(),
          current_question: Question.t(),
          last_response: Response.t(),
          templates: %{optional(category :: binary()) => [Template.t()]},
          used: [Template.t()],
          mastered: [Template.t()],
          record: %{optional(template_name :: binary()) => integer()}
        }
end
