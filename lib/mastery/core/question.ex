defmodule DFTBLW.Mastery.Core.Question do
  @moduledoc """
  A question for a template.

  Templates generate questions and questions are instantiations of templates.
  """

  defstruct ~w[asked template substitutions]a

  alias DFTBLW.Mastery.Core.Template

  @type t :: %__MODULE__{
          asked: binary(),
          template: Template.t(),
          substitutions: substitution_t()
        }

  @type substitution_t() :: %{
          substitution: any()
        }
end
