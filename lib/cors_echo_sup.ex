defmodule CORSEcho.Supervisor do
  use Supervisor.Behaviour

  def start_link(app) do
    :supervisor.start_link(__MODULE__, app)
  end

  def init(app) do
    children = [
      # worker(some_worker, [app]),
      supervisor(CORSEcho.Dynamo, [app])
    ]
    supervise children, strategy: :one_for_one
  end
end
