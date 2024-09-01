defmodule Elixis.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {DynamicSupervisor, name: Elixis.BucketSupervisor, strategy: :one_for_one},
      {Elixis.Registry, name: Elixis.Registry},
      {Task.Supervisor, name: Elixis.RouterTasks}
    ]

    # we want the bucket supervisor to shut down whenever we lose the registry, since otherwise we would end with
    # buckets that can't be accessed from anywhere. we also need to start the bucket supervisor first since the
    # registry will use it to start new buckets.
    #
    # rest_for_one strategy: supervisor will kill and restart children that were started AFTER the child that crashed.
    # this approach is not viable in our case since the supervisor needs to start before the registry
    #
    # one_for_all startegy: supervisor will kill all children whenever one child process dies. this works in our case
    # because 1) if we lose the supervisor, the registry won't be able to access the buckets and 2) if we lose the
    # registry, the buckets can't be accessed

    Supervisor.init(children, strategy: :one_for_all)
  end
end
