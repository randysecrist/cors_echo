alias API.Config

ExUnit.configure(exclude: [pending: true])
ExUnit.start(timeout: 75000)

defmodule API.Test.Helper do
  use ExUnit.Case, async: true

  @spec load_fixture(String.t) :: binary()
  def load_fixture(fixture_file) do
    {:ok, binary} = File.read "test/fixtures/" <> fixture_file
    binary
  end

  @spec options(String.t) :: binary()
  def options(url) do
    :application.ensure_all_started(:gun)
    {_, port} = Config.get_bind_address()
    options = case Config.get_protocol do
      :http -> %{:protocols => [:http2]}
      _ -> %{:protocols => [:http2], :transport => :ssl}
    end
    {:ok, pid} = :gun.open('localhost', port, options)
    stream_ref = :gun.options(pid, url)
    read_stream(pid, stream_ref)
  end

  @spec head(String.t) :: binary()
  def head(url) do
    :application.ensure_all_started(:gun)
    {_, port} = Config.get_bind_address()
    options = case Config.get_protocol do
      :http -> %{:protocols => [:http2]}
      _ -> %{:protocols => [:http2], :transport => :ssl}
    end
    {:ok, pid} = :gun.open('localhost', port, options)
    stream_ref = :gun.head(pid, url)
    read_stream(pid, stream_ref)
  end

  @spec get(String.t) :: binary()
  def get(url) do
    :application.ensure_all_started(:gun)
    {_, port} = Config.get_bind_address()
    options = case Config.get_protocol do
      :http -> %{:protocols => [:http2]}
      _ -> %{:protocols => [:http2], :transport => :tls}
    end
    {:ok, pid} = :gun.open('localhost', port, options)
    stream_ref = :gun.get(pid, url)
    read_stream(pid, stream_ref)
  end

  @spec post(String.t, String.t) :: binary()
  def post(body, url) do
    :application.ensure_all_started(:gun)
    {_, port} = Config.get_bind_address()
    options = case Config.get_protocol do
      :http -> %{:protocols => [:http2]}
      _ -> %{:protocols => [:http2], :transport => :ssl}
    end
    {:ok, pid} = :gun.open('localhost', port, options)
    stream_ref = :gun.post(pid, url, [
      {"content-type", 'application/json'}
    ], body)
    read_stream(pid, stream_ref)
  end

  @spec put(String.t, String.t) :: binary()
  def put(body, url) do
    :application.ensure_all_started(:gun)
    {_, port} = Config.get_bind_address()
    options = case Config.get_protocol do
      :http -> %{:protocols => [:http2]}
      _ -> %{:protocols => [:http2], :transport => :ssl}
    end
    {:ok, pid} = :gun.open('localhost', port, options)
    stream_ref = :gun.put(pid, url, [
      {"content-type", 'application/json'}
    ], body)
    read_stream(pid, stream_ref)
  end

  @spec delete(String.t) :: binary()
  def delete(url), do: delete("", url)

  @spec delete(String.t, String.t) :: binary()
  def delete(body, url) do
    :application.ensure_all_started(:gun)
    {_, port} = Config.get_bind_address()
    options = case Config.get_protocol do
      :http -> %{:protocols => [:http2]}
      _ -> %{:protocols => [:http2], :transport => :ssl}
    end
    {:ok, pid} = :gun.open('localhost', port, options)
    stream_ref = :gun_patch.delete(pid, url, [
      {"content-type", 'application/json'}
    ], body, %{})
    read_stream(pid, stream_ref)
  end

  @spec wait_until(integer(), function()|function()) :: any()
  def wait_until(fun), do: wait_until(500, fun)
  def wait_until(0, fun), do: fun.()
  def wait_until(timeout, fun) do
    try do
      fun.()
    rescue
      _ ->
        :timer.sleep(10)
        wait_until(max(0, timeout - 10), fun)
    end
  end

  defp read_stream(pid, stream_ref) do
    case :gun.await(pid, stream_ref) do
      {:response, :fin, status, headers} ->
        %{status: status, headers: headers}
      {:response, :nofin, status, headers} ->
        {:ok, body} = :gun.await_body(pid, stream_ref)
        %{body: body, headers: headers, status: status}
      {:error, :timeout} -> {:error, :timeout}
    end
  end

  # mock just one thing
  # note; any test that does this should not be marked as async
  defmacro mocking(module, fun, replacement, do: body) do
    quote do
      :meck.new(unquote(module))

      :meck.expect(
        unquote(module),
        unquote(fun),
        unquote(replacement)
      )

      result = unquote(body)
      :meck.unload(unquote(module))
      result
    end
  end

  # mock multiple module and functions
  # note; any test that does this should not be marked as async
  defmacro mocking(mfa_list, do: body) do
    quote do
      module_list  = unquote(mfa_list) |> Enum.reduce([], fn {m, _f, _r}, acc ->
        [m | acc]
      end)

      :meck.new(module_list, [:non_strict])

      unquote(mfa_list) |> Enum.each(fn {module, fun, replacement} ->
        :meck.expect(module, fun, replacement)
      end)

      result = unquote(body)
      :meck.unload(module_list)
      result
    end
  end

end
