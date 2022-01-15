defmodule DFTBLW.Mastery.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias DFTBLW.Mastery

  @impl true
  def start(_type, _args) do
    children = [
      {Mastery.Boundary.QuizManager, [name: DFTBLW.Mastery.Boundary.QuizManager]},
      {Registry, [name: DFTBLW.Mastery.Registry.QuizSession, keys: :unique]},
      {Mastery.Boundary.Proctor, [name: Mastery.Boundary.Proctor]},
      {DynamicSupervisor, [name: DFTBLW.Mastery.Supervisor.QuizSession, strategy: :one_for_one]}
    ]

    opts = [strategy: :one_for_one, name: DFTBLW.Mastery.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
