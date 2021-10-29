defmodule DFTBLW.Counter.Core do
  @moduledoc """
  The Functional Core of the Counter component
  """

  @doc """
  Increment the counter's value.
  """
  @spec inc(integer()) :: integer()
  def inc(value) do
    value + 1
  end
end
