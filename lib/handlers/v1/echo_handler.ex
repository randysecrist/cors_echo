alias API.Error, as: E
alias API.Response

defmodule API.EchoHandler do
  use API.Handler

  def init(req0, opts) do
    method = :cowboy_req.method(req0)
    bindings = :cowboy_req.bindings(req0)
    {:ok, handle(method, bindings, req0), opts}
  end

  def handle("GET", _bindings, req0) do
    %{
      :hostname => hostname,
      :path => path,
      :port => port,
      :qs => qs
    } = to_map(:cowboy_req.parse_qs(req0))
    response = get(hostname, port, path <> "?" <> qs)
    req0 |> Response.send(200, response |> Map.get(:body))
  end
  def handle(_method, _bindings, req0) do
    req0 |> Response.send(E.make(:not_found))
  end

  defp to_map(qs) do
    map = qs |> Enum.into(%{}) # don't care about param order
    %{
      :hostname => map |> Map.get("hostname"),
      :path => map |> Map.get("path"),
      :port => map |> Map.get("port") |> String.to_integer,
      :qs => map |> Map.get("qs")
    }
  end

  @spec get(binary(), Integer.t, String.t) :: binary()
  defp get(host, port, url) when is_binary(host) do
    get(host |> String.to_charlist, port, url)
  end

  @spec get(list(), Integer.t, String.t) :: binary()
  defp get(host, port, url) when is_list(host) do
    :application.ensure_all_started(:gun)
    options = %{
      :protocols => [:http],
      :transport => :tls,
    }
    {:ok, pid} = :gun.open(host, port, options)
    stream_ref = :gun.get(pid, url)
    read_stream(pid, stream_ref, 5000)
  end

  defp read_stream(pid, stream_ref, timeout) do
    case :gun.await(pid, stream_ref, timeout) do
      {:response, :fin, status, headers} ->
        %{status: status, headers: headers}
      {:response, :nofin, status, headers} ->
        {:ok, body} = :gun.await_body(pid, stream_ref, timeout)
        %{body: body, headers: headers, status: status}
      {:error, :timeout} -> {:error, :timeout}
    end
  end
end
