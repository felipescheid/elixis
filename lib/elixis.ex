defmodule Elixis do
  use Application

  @impl true
  def start(_type, _args) do
    Elixis.Supervisor.start_link(name: Elixis.Supervisor)
  end
end
