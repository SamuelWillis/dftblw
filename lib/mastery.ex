defmodule DFTBLW.Mastery do
  alias DFTBLW.Mastery.Boundary.Proctor
  alias DFTBLW.Mastery.Boundary.QuizManager
  alias DFTBLW.Mastery.Boundary.QuizSession
  alias DFTBLW.Mastery.Boundary.QuizValidator
  alias DFTBLW.Mastery.Boundary.TemplateValidator
  alias DFTBLW.Mastery.Core.Quiz

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
end
