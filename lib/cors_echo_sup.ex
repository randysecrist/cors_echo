defmodule CORSEcho.Supervisor do
  use Supervisor.Behaviour

  def start_link(app) do
    :supervisor.start_link(__MODULE__, app)
  end

  def init(app) do
    HTTPoison.start
    children = [
      # TODO:  define HTTPoison as a separate worker
      #worker(HTTPoison, [app]),
      supervisor(CORSEcho.Dynamo, [])
    ]
    supervise children, strategy: :one_for_one
  end
end
