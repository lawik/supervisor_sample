# SupervisorSample

In spite of supervision trees being one of the most important parts of the Elixir application development experience I haven't seen an example I like recently. At least not since the `Supervisor.Spec` module was deprecated. So I figured I'd set something up.

I'm sure there are other good examples that I haven't found. I hope this helps someone grasp what the trees look like without the child_spec definitions getting in the way or the module-based supervisors blowing your mind-state all apart.

You can see the structure of the tree in this sample application in `lib/supervisor_sample/application.ex`.

You can run it with `iex -S mix` and then call `SupervisorSample.Worker.stop(:worker_4)` to see some of the behavior.

The tests in `test/supervisor_sample_test.exs` demonstrate the behaviour of the different supervisor strategies. Transient vs. permanent workers and such. You can run the tests with `mix test`.

If there is interest in having it built out with DynamicSupervisor examples. Let me know. Should be simple enough.