alias API.Error, as: E
alias API.Response

defmodule API.PingHandler do
  @moduledoc ~S"""
  Responds to health check requests using HTTP HEAD and GET.

  Returns :not_found (404) otherwise.
  """
  use API.Handler
  def init(req0, opts) do
    method = :cowboy_req.method(req0)
    bindings = :cowboy_req.bindings(req0)
    {:ok, handle(method, bindings, req0), opts}
  end

  def handle("HEAD", _bindings, req0) do
    req0 |> Response.send(204)
  end
  def handle("GET", _bindings, req0) do
    req0 |> Response.send(200, %{:status => :ok})
  end
  def handle(_method, _bindings, req0) do
    req0 |> Response.send(E.make(:not_found))
  end
end
