defmodule DFTBLW.Counter.Server do
  @moduledoc """
  A home rolled server that mimics a GenServer for learning purposes

  This is used to store the state of the counter.

  To do so a loop is ran, with each iteration of the loop containing the new
  state.
  """

  alias DFTBLW.Counter.Core

  @doc """
  Run the loop.

  listens for any new messages and passes the new state to the next iteration
  """
  @spec run(count :: integer()) :: integer()
  def run(count), do: count |> listen() |> run()

  @doc """
  Listen for any messages sent to the server.
  """
  @spec listen(count :: integer()) :: integer()
  def listen(count) do
    receive do
      {:tick, _pid} ->
        Core.inc(count)

      {:state, pid} ->
        send(pid, {:count, count})
        count
    end
  end
end
