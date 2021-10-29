defmodule DFTBLW.Counter do
  @moduledoc """
  Counter module.

  The public API for the Counter component
  """

  alias DFTBLW.Counter.Server

  @doc """
  Start the counter service
  """
  @spec start(initial_count :: integer()) :: pid()
  def start(initial_count) do
    spawn(Server, :run, [initial_count])
  end

  @doc """
  Tick the service.

  Increments the counter.

  Why is this called tick?
  """
  @spec tick(pid()) :: any()
  def tick(pid), do: send(pid, {:tick, self()})

  @doc """
  Retrieve the state of the Counter
  """
  @spec state(pid()) :: integer()
  def state(pid) do
    send(pid, {:state, self()})

    receive do
      {:count, value} -> value
    end
  end
end
