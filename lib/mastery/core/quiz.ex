defmodule DFTBLW.Mastery.Core.Quiz do
  @moduledoc """
  A quiz a user goes through to prove their mastery.

  A quiz will ask questions until the user achieves mastery.

  Takes a set of templates organized by category and cycles through them.
  Once the user answers enough questions correctly in a row, we stop asking the
  question


  A BIG QUESTION I have is why a lot of these functions do not exist on a Core module
  rather than inside of this data structure?

  Maybe it'll move, but I almost feel like a lot of this funnctionality should be in a
  "Functional Core" as it was in the simpler Counter example

  This module is begining to feel somewhat God-like as it handles co-ordinating so many things.
  Possibly some of the helpers could be pulled to the modules they're working on.
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

  @doc """
  Construct a new quiz
  """
  def new(fields), do: struct!(__MODULE__, fields)

  @doc """
  Add a template to the quiz.
  """
  @spec add_template(t(), template_fields :: keyword()) :: t()
  def add_template(%__MODULE__{} = quiz, template_fields) do
    template = Template.new(template_fields)

    templates =
      update_in(
        quiz.templates,
        [template.category],
        &add_to_list_or_nil(&1, template)
      )

    %{quiz | templates: templates}
  end

  @doc """
  Selects a question.
  """
  @spec select_question(t()) :: t() | nil
  def select_question(%__MODULE__{} = quiz) when map_size(quiz.templates) != 0 do
    quiz
    |> pick_current_question()
    |> move_template(:used)
    |> reset_template_cycle()
  end

  def select_question(%__MODULE__{}), do: nil

  @doc """
  Answer a question based on correctness of response.

  Updates the number of correct answers in a row and marks mastery if
  applicable.
  """
  @spec answer_question(t(), Response.t()) :: t()
  def answer_question(%__MODULE__{} = quiz, %Response{} = response)
      when response.correct == true do
    new_quiz =
      quiz
      |> inc_record()
      |> save_response(response)

    mastered? = mastered?(new_quiz)

    advance(new_quiz, mastered?)
  end

  def answer_question(quiz, %Response{} = response) do
    quiz
    |> reset_record()
    |> save_response(response)
  end

  defp pick_current_question(quiz),
    do: Map.put(quiz, :current_question, select_random_question(quiz))

  defp move_template(quiz, field),
    do: quiz |> remove_template_from_category() |> add_template_to_field(field)

  defp reset_template_cycle(quiz) when map_size(quiz.templates) == 0 do
    quiz_templates = Enum.group_by(quiz.used, & &1.category)

    %__MODULE__{
      quiz
      | templates: quiz_templates,
        used: []
    }
  end

  defp reset_template_cycle(quiz), do: quiz

  defp add_to_list_or_nil(templates, template) when is_list(templates), do: [template | templates]
  defp add_to_list_or_nil(_templates, template), do: [template]

  defp select_random_question(quiz),
    do: quiz.templates |> Enum.random() |> elem(1) |> Enum.random() |> Question.new()

  defp template(quiz), do: quiz.current_question.template

  defp remove_template_from_category(quiz) do
    template = template(quiz)

    new_category_templates =
      quiz.templates |> Map.fetch!(template.category) |> List.delete(template)

    new_templates =
      if new_category_templates == [],
        do: Map.delete(quiz.templates, template.category),
        else: Map.put(quiz.templates, template.category, new_category_templates)

    %{quiz | templates: new_templates}
  end

  defp add_template_to_field(quiz, field) do
    template = template(quiz)

    list = Map.get(quiz, field)

    Map.put(quiz, field, [template | list])
  end

  defp inc_record(quiz) do
    current_question = quiz.current_question
    template_name = current_question.template.name

    new_record = Map.update(quiz.record, template_name, 1, &(&1 + 1))

    Map.put(quiz, :record, new_record)
  end

  defp save_response(quiz, response), do: Map.put(quiz, :last_response, response)

  defp mastered?(quiz) do
    template = template(quiz)
    score = Map.get(quiz.record, template.name, 0)

    score == quiz.mastery
  end

  defp advance(quiz, mastered) when mastered == true do
    quiz
    |> move_template(:mastered)
    |> reset_record()
    |> reset_used()
  end

  defp advance(quiz, _mastered), do: quiz

  defp reset_record(quiz) do
    current_question = quiz.current_question

    template_name = current_question.template.name

    new_record = Map.delete(quiz.record, template_name)

    Map.put(quiz, :record, new_record)
  end

  defp reset_used(quiz) do
    current_question = quiz.current_question
    new_used = List.delete(quiz.used, current_question.template)

    Map.put(quiz, :used, new_used)
  end
end
