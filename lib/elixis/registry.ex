defmodule Elixis.Registry do
  use GenServer

  ## Client API
  @doc """
  Starts the registry

  `:name` is always required
  """
  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`

  Returns {:ok, pid} if bucket exists, :error otherwise
  """
  def lookup(server, name) do
    # Lookup is done in ETS, no need to access the server
    case :ets.lookup(server, name) do
      # ^ is the pin operator - we use it to NOT reassign the name variable
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket with the given `name` in `server`
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  ## Defining GenServer Callbacks

  @impl true
  def init(table) do
    # by default, the ETS table has the :protected option enabled, which means that only the registry process
    # will be able to write to it. all other processes will be able to read from the table
    # the read_concurrency option optimizes for concurrent reads
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:create, name}, _from, {names, refs}) do
    case lookup(names, name) do
      {:ok, pid} ->
        {:reply, pid, {names, refs}}

      :error ->
        {:ok, pid} = DynamicSupervisor.start_child(Elixis.BucketSupervisor, Elixis.Bucket)
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, pid})
        {:reply, pid, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # pop returns both the removed value and the updated map
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in Elixis.Registry: #{inspect(msg)}")
    {:noreply, state}
  end
end
