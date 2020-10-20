defmodule SupervisorSampleTest do
  use ExUnit.Case
  doctest SupervisorSample

  setup do
    :pg2.create(:feedback)
    # Join feedback group so we can listen for messages from worker processes
    :pg2.join(:feedback, self())
    :ok
  end

  alias SupervisorSample.Worker

  test "restart root worker" do
    Worker.stop(:root_worker)

    # Should restart
    assert_receive {:stopped, :root_worker}
    assert_receive {:started, :root_worker}
    # Shouldn't restart anything else
    refute_received {:stopped, _}
    refute_received {:started, _}
  end

  test "stop transient worker, no restart" do
    Worker.stop(:transient_root_worker)

    # Should restart
    assert_receive {:stopped, :transient_root_worker}
    refute_receive {:started, :transient_root_worker}
    # Shouldn't restart anything else
    refute_received {:stopped, _}
    refute_received {:started, _}
  end

  test "strategy one-for-one, restart worker 1 and then 2" do
    Worker.stop(:worker_1)

    assert_receive {:stopped, :worker_1}
    assert_receive {:started, :worker_1}
    refute_received {:stopped, :worker_2}
    refute_received {:started, :worker_2}

    Worker.stop(:worker_2)

    assert_receive {:stopped, :worker_2}
    assert_receive {:started, :worker_2}
    refute_received {:stopped, :worker_1}
    refute_received {:started, :worker_1}
  end

  test "strategy rest-for-one, restart worker 3, then 4, then 5" do
    Worker.stop(:worker_3)

    assert_receive {:stopped, :worker_3}
    assert_receive {:started, :worker_3}
    assert_receive {:stopped, :worker_4}
    assert_receive {:started, :worker_4}
    assert_receive {:stopped, :worker_5}
    assert_receive {:started, :worker_5}
    assert_receive {:stopped, :subworker_1}
    assert_receive {:started, :subworker_1}

    Worker.stop(:worker_4)

    refute_received {:stopped, :worker_3}
    refute_received {:started, :worker_3}
    assert_receive {:stopped, :worker_4}
    assert_receive {:started, :worker_4}
    assert_receive {:stopped, :worker_5}
    assert_receive {:started, :worker_5}
    assert_receive {:stopped, :subworker_1}
    assert_receive {:started, :subworker_1}

    Worker.stop(:worker_5)

    refute_received {:stopped, :worker_3}
    refute_received {:started, :worker_3}
    refute_received {:stopped, :worker_4}
    refute_received {:started, :worker_4}
    assert_receive {:stopped, :worker_5}
    assert_receive {:started, :worker_5}
    assert_receive {:stopped, :subworker_1}
    assert_receive {:started, :subworker_1}
  end

  test "strategy one-for-all, restart any worker, all restart" do
    Worker.stop(:worker_6)

    assert_receive {:stopped, :worker_6}
    assert_receive {:started, :worker_6}
    assert_receive {:stopped, :worker_7}
    assert_receive {:started, :worker_7}
    assert_receive {:stopped, :worker_8}
    assert_receive {:started, :worker_8}

    Worker.stop(:worker_7)

    assert_receive {:stopped, :worker_6}
    assert_receive {:started, :worker_6}
    assert_receive {:stopped, :worker_7}
    assert_receive {:started, :worker_7}
    assert_receive {:stopped, :worker_8}
    assert_receive {:started, :worker_8}

    Worker.stop(:worker_8)

    assert_receive {:stopped, :worker_6}
    assert_receive {:started, :worker_6}
    assert_receive {:stopped, :worker_7}
    assert_receive {:started, :worker_7}
    assert_receive {:stopped, :worker_8}
    assert_receive {:started, :worker_8}
  end
end
