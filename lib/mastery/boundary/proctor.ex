defmodule DFTBLW.Mastery.Boundary.Proctor do
  use GenServer

  require Logger

  alias DFTBLW.Mastery.Boundary.QuizManager
  alias DFTBLW.Mastery.Boundary.QuizSession

  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, [], opts)

  @impl GenServer
  def init(quizzes), do: {:ok, quizzes}

  def schedule_quiz(proctor \\ __MODULE__, quiz, templates, start_at, end_at) do
    quiz = %{
      fields: quiz,
      templates: templates,
      start_at: start_at,
      end_at: end_at
    }

    GenServer.call(proctor, {:schedule_quiz, quiz})
  end

  @impl GenServer
  def handle_call({:schedule_quiz, quiz}, _from, quizzes) do
    now = DateTime.utc_now()

    ordered_quizzes =
      [quiz | quizzes]
      |> start_quizzes(now)
      |> Enum.sort(&(DateTime.compare(&1, &2) in [:lt, :eq]))

    build_reply_with_timeout({:reply, :ok}, ordered_quizzes, now)
  end

  @impl GenServer
  def handle_info(:timeout, quizzes) do
    now = DateTime.utc_now()
    remaining_quizzes = start_quizzes(quizzes, now)

    build_reply_with_timeout({:noreply}, remaining_quizzes, now)
  end

  def handle_info({:end_quiz, title}, quizzes) do
    QuizManager.remove_quiz(title)

    title
    |> QuizSession.active_sessions_for()
    |> QuizSession.end_sessions()

    Logger.info("Stopped quiz #{title}")

    handle_info(:timeout, quizzes)
  end

  defp start_quizzes(quizzes, now) do
    {ready, not_ready} =
      Enum.split_while(quizzes, &(DateTime.compare(&1.start_at, now) in [:lt, :eq]))

    Enum.each(ready, &start_quiz(&1, now))

    not_ready
  end

  defp start_quiz(quiz, now) do
    Logger.info("Starting quiz #{quiz.fields.title}")

    QuizManager.build_quiz(quiz.fields)

    Enum.each(quiz.templates, &QuizManager.add_template(quiz.fields.title, &1))

    timeout = DateTime.diff(quiz.end_at, now, :millisecond)

    Process.send_after(self(), {:end_quiz, quiz.fields.title}, timeout)
  end

  defp build_reply_with_timeout(reply, quizzes, now) do
    reply
    |> append_state(quizzes)
    |> append_timeout(quizzes, now)
  end

  defp append_state(reply, quizzes), do: Tuple.append(reply, quizzes)

  defp append_timeout(reply, [], _now), do: reply

  defp append_timeout(reply, quizzes, now) do
    timeout =
      quizzes
      |> hd()
      |> Map.fetch!(:start_at)
      |> DateTime.diff(now, :millisecond)

    Tuple.append(reply, timeout)
  end
end
