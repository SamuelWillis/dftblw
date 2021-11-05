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

  def new(%Template{} = template) do
    template.generators
    |> Enum.map(&build_substitution/1)
    |> evaluate(template)
  end

  defp build_substitution({name, choices_or_generator}), do: {name, choose(choices_or_generator)}

  defp evaluate(substitutions, template) do
    %__MODULE__{
      asked: compile(template, substitutions),
      substitutions: substitutions,
      template: template
    }
  end

  defp compile(template, substitutions),
    do: template.compiled |> Code.eval_quoted(assigns: substitutions) |> elem(0)

  defp choose(choices) when is_list(choices), do: Enum.random(choices)
  defp choose(generator) when is_function(generator), do: generator.()
end
