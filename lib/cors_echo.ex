defmodule CORSEcho do
  use Application.Behaviour

  @doc """
  The application callback used to start this
  application and its Dynamos.
  """
  def start(_type, _args) do
    Lager.compile_log_level(:info)
    Lager.compile_truncation_size(256)
    # Start clean w/ mix server and release
    # CORSEcho.Dynamo.run
    CORSEcho.Supervisor.start_link([])
  end
end
