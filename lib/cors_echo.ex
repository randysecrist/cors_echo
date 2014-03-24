defmodule CORSEcho do
  use Application.Behaviour

  @doc """
  The application callback used to start this
  application and its Dynamos.
  """
  def start(_type, _args) do
    CORSEcho.Dynamo.run
    CORSEcho.Supervisor.start_link([])
  end

  def stop(_state) do
    Dynamo.Cowboy.shutdown CORSEcho.Dynamo
  end

end
