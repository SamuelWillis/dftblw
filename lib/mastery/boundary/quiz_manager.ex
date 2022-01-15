defmodule DFTBLW.Mastery.Boundary.QuizManager do
  use GenServer

  alias DFTBLW.Mastery.Core.Quiz

  @impl GenServer
  def init(quizzes) when is_map(quizzes),
    do: {:ok, quizzes}

  def init(_quizzes), do: {:error, "quizzes must be a map"}

  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, %{}, opts)

  def build_quiz(manager \\ __MODULE__, quiz_fields),
    do: GenServer.call(manager, {:build_quiz, quiz_fields})

  def remove_quiz(manager \\ __MODULE__, quiz_title),
    do: GenServer.call(manager, {:remove_quiz, quiz_title})

  def add_template(manager \\ __MODULE__, quiz_title, template_fields),
    do: GenServer.call(manager, {:add_template, quiz_title, template_fields})

  def lookup_quiz_by_title(manager \\ __MODULE__, quiz_title),
    do: GenServer.call(manager, {:lookup_quiz_by_title, quiz_title})

  @impl GenServer
  def handle_call({:build_quiz, quiz_fields}, _from, quizzes) do
    quiz = Quiz.new(quiz_fields)

    {:reply, :ok, Map.put(quizzes, quiz.title, quiz)}
  end

  def handle_call({:remove_quiz, quiz_title}, _from, quizzes) do
    new_quizzes = Map.delete(quizzes, quiz_title)

    {:reply, :ok, new_quizzes}
  end

  def handle_call({:add_template, quiz_title, template_fields}, _from, quizzes) do
    new_quizzes =
      Map.update!(quizzes, quiz_title, fn quiz ->
        Quiz.add_template(quiz, template_fields)
      end)

    {:reply, :ok, new_quizzes}
  end

  def handle_call({:lookup_quiz_by_title, quiz_title}, _from, quizzes),
    do: {:reply, quizzes[quiz_title], quizzes}
end
