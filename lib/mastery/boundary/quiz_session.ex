defmodule DFTBLW.Mastery.Boundary.QuizSession do
  alias DFTBLW.Mastery.Core.Quiz
  alias DFTBLW.Mastery.Core.Response

  use GenServer

  def take_quiz(quiz, email),
    do:
      DynamicSupervisor.start_child(
        DFTBLW.Mastery.Supervisor.QuizSession,
        {__MODULE__, {quiz, email}}
      )

  def select_question(name), do: GenServer.call(via(name), :select_question)

  def answer_question(name, answer, persistence_fn),
    do: GenServer.call(via(name), {:answer_question, answer, persistence_fn})

  def active_sessions_for(quiz_title) do
    DFTBLW.Mastery.Supervisor.QuizSession
    |> DynamicSupervisor.which_children()
    |> Enum.filter(&child_pid?/1)
    |> Enum.flat_map(&active_sessions(&1, quiz_title))
  end

  def end_sessions(names), do: Enum.each(names, &(&1 |> via() |> GenServer.stop()))

  def via({_title, _email} = name),
    do: {:via, Registry, {DFTBLW.Mastery.Registry.QuizSession, name}}

  @impl GenServer
  def init({quiz, email}), do: {:ok, {quiz, email}}

  def start_link({quiz, email}),
    do: GenServer.start_link(__MODULE__, {quiz, email}, name: via({quiz.title, email}))

  def child_spec({quiz, email}),
    do: %{
      id: {__MODULE__, {quiz.title, email}},
      start: {__MODULE__, :start_link, [{quiz, email}]},
      restart: :temporary
    }

  @impl GenServer
  def handle_call(:select_question, _from, {quiz, email}) do
    quiz = Quiz.select_question(quiz)

    {:reply, quiz.current_question.asked, {quiz, email}}
  end

  def handle_call({:answer_question, answer, persistence_fn}, _from, {quiz, email}) do
    persistence_fn = persistence_fn || fn r, f -> f.(r) end
    response = Response.new(quiz, email, answer)

    persistence_fn.(response, fn r ->
      quiz
      |> Quiz.answer_question(response)
      |> Quiz.select_question()
    end)
    |> maybe_finish(email)
  end

  defp maybe_finish(nil, _email), do: {:stop, :normal, :finished, nil}

  defp maybe_finish(quiz, email),
    do: {:reply, {quiz.current_question.asked, quiz.last_response.correct}, {quiz, email}}

  defp child_pid?({:undefined, pid, :worker, [__MODULE__]}) when is_pid(pid), do: true
  defp child_pid?(_child), do: false

  defp active_sessions({:undefined, pid, :worker, [__MODULE__]}, title) do
    DFTBLW.Mastery.Registry.QuizSession
    |> Registry.keys(pid)
    |> Enum.filter(fn {quiz_title, _email} -> quiz_title == title end)
  end
end
