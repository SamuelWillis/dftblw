defmodule DFTBLW.DFTBLW.CounterTest do
  use ExUnit.Case

  describe "DFTBLW.Counter" do
    test "use counter through API" do
      pid = DFTBLW.Counter.start(0)

      assert DFTBLW.Counter.state(pid) == 0

      DFTBLW.Counter.tick(pid)
      DFTBLW.Counter.tick(pid)

      assert DFTBLW.Counter.state(pid) == 2
    end
  end

  describe "DFTBLW.Counter.Core" do
    test "inc increments an integer value" do
      assert DFTBLW.Counter.Core.inc(0) == 1
    end
  end
end
