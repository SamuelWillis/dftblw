defmodule DFTBLW.Mastery.Core.Template do
  @moduledoc """
  Creates a question for a specific category.

  Can be used to:
  - Represent a grouping of questions on a quiz
  - Generate questions with a compilable template and functions
  - Check the response of a single question in the template
  """

  defstruct ~w[name category instructions raw compiled generators checker]a

  @type t :: %__MODULE__{
          name: atom(),
          category: atom(),
          instructions: binary(),
          raw: binary(),
          compiled: any(),
          generators: generator_t()
        }

  @type generator_t :: %{
          substitution: list() | function()
        }
end
