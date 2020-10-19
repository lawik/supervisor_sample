defmodule SupervisorSample.Worker do
  use GenServer

  @moduledoc """
  This is a simple worker GenServer that only exists to demonstrate starting and stopping
  in a supervision tree.

  Sends messages to interested parties to indicate when it stops and starts.
  """

  # Starting point when starting the worker, default stuff
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:label], opts)
  end

  @doc """
  Convenience function for stopping a worker.
  """
  def stop(worker) do
    GenServer.stop(worker)
  end

  # Required callback/hook for GenServer startup
  @impl GenServer
  def init(label) do
    # Make sure the process group for interested parties exists
    # Does nothing if it doesn't, so it's fine
    :pg2.create(:feedback)
    # Trap exits, this means our terminate function is called for a normal stop
    Process.flag(:trap_exit, true)

    # Nice dumb logging for running in iEx
    log("#{label}: starting")
    # Broadcast startup message
    broadcast(label, :started)

    {:ok, label}
  end

  # Termination callback/hook, part of the GenServer implementation
  @impl GenServer
  def terminate(_reason, label) do
    log("#{label}: terminating")
    broadcast(label, :stopped)
  end

  # Sends the event to everyone joined to the feedback group, for tests
  defp broadcast(label, event) do
    :pg2.get_members(:feedback)
    |> Enum.each(fn pid ->
      Process.send(pid, {event, label}, [:nosuspend])
    end)
  end

  # Duct taped log only if we aren't running tests
  defp log(label) do
    if Mix.env() != :test do
      IO.puts(label)
    end
  end
end
