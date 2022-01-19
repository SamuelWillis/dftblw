defmodule DFTBLW.Mastery do
  import Ecto.Query, only: [from: 2]

  alias DFTBLW.Mastery.Boundary.Proctor
  alias DFTBLW.Mastery.Boundary.QuizManager
  alias DFTBLW.Mastery.Boundary.QuizSession
  alias DFTBLW.Mastery.Boundary.QuizValidator
  alias DFTBLW.Mastery.Boundary.TemplateValidator
  alias DFTBLW.Mastery.Core.Quiz
  alias DFTBLW.Mastery.Persistence.Response
  alias DFTBLW.Repo

  @quiz_manager QuizManager

  def build_quiz(fields) do
    with :ok <- QuizValidator.errors(fields),
         :ok <- QuizManager.build_quiz(@quiz_manager, fields),
         do: :ok,
         else: (error -> error)
  end

  def schedule_quiz(quiz, templates, start_at, end_at) do
    with :ok <- QuizValidator.errors(quiz),
         true <- Enum.all?(templates, &(:ok == TemplateValidator.errors(&1))),
         :ok <- Proctor.schedule_quiz(quiz, templates, start_at, end_at),
         do: :ok,
         else: (error -> error)
  end

  def add_template(title, fields) do
    with :ok <- TemplateValidator.errors(fields),
         :ok <- QuizManager.add_template(@quiz_manager, title, fields),
         do: :ok,
         else: (error -> error)
  end

  def take_quiz(title, email) do
    with %Quiz{} = quiz <- QuizManager.lookup_quiz_by_title(title),
         {:ok, _} <- QuizSession.take_quiz(quiz, email),
         do: {quiz, email},
         else: (error -> error)
  end

  def select_question(session), do: QuizSession.select_question(session)

  def answer_question(session, answer), do: QuizSession.answer_question(session, answer)

  def record_response(response, in_transaction \\ fn _response -> :ok end) do
    {:ok, result} =
      Repo.transaction(fn ->
        %{
          quiz_title: to_string(response.quiz_title),
          template_name: to_string(response.template_name),
          to: response.to,
          email: response.email,
          answer: response.answer,
          correct: response.correct,
          inserted_at: response.timestamp,
          updated_at: response.timestamp
        }
        |> Response.record_changeset()
        |> Repo.insert!()

        in_transaction.(response)
      end)

    result
  end

  def report(quiz_title) do
    quiz_title = to_string(quiz_title)

    query =
      from(r in Response,
        select: {r.email, count(r.id)},
        where: r.quiz_title == ^quiz_title,
        group_by: [r.quiz_title, r.email]
      )

    query
    |> Repo.all()
    |> Enum.into(Map.new())
  end
end
