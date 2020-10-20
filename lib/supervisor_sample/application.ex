defmodule SupervisorSample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias SupervisorSample.Worker

  def start(_type, _args) do
    children = [
      worker(:root_worker),
      supervisor(
        :one_for_one,
        [
          worker(:worker_1),
          worker(:worker_2)
        ],
        name: :supervisor_1
      ),
      supervisor(
        :rest_for_one,
        [
          worker(:worker_3),
          worker(:worker_4),
          worker(:worker_5),
          supervisor(
            :one_for_one,
            [worker(:subworker_1)],
            name: :subsupervisor_1
          )
        ],
        name: :supervisor_2
      ),
      supervisor(
        :one_for_all,
        [
          worker(:worker_6),
          worker(:worker_7),
          worker(:worker_8)
        ],
        name: :supervisor_3
      ),
      worker(:transient_root_worker, :transient)
    ]

    # The root of the tree is a supervisor that runs everything we defined above
    opts = [strategy: :one_for_one, name: SupervisorSample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Supervisor child specs require unique IDs, we don't have any particular needs for
  # those so we let Erlang give us something unique enough
  defp id, do: :erlang.unique_integer()

  # A utility function to make the above tree more readable.
  # The supervisor child specs can look unwieldy but they aren't actually very complex
  # They require an :id key. They define how to :start the process by giving:
  # Module, function and a list of args
  # A Supervisor requires a strategy and children, we also want to add a name, so we
  # support these directly.
  defp supervisor(strategy, children, options) do
    options = Keyword.put(options, :strategy, strategy)

    %{
      id: id(),
      start: {Supervisor, :start_link, [children, options]}
    }
  end

  # Utility function that modifies the Worker module child spec (it has one by being a)
  # GenServer. But we want to override the :id key (or we can't start multiple ones) and
  # we want to set names.
  # We also allow changing the restart behavior
  defp worker(name, restart \\ :permanent) do
    Supervisor.child_spec({Worker, [label: name, name: name]}, id: id(), restart: restart)
  end
end
