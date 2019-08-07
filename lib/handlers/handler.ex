defmodule API.Handler do
  @moduledoc ~S"""
  A simple macro which specifies what happens to a request should
  it fall through and hit a GPF (general protection fault) condition.

  This also specifies a default_timeout of 500ms per request.
  """
  defmacro __using__(_) do
    quote do
      require Logger
      def default_timeout() do
        500
      end
      def terminate(reason, request, state) do
        case reason do
          :normal -> :ok
          {:crash, status, type} ->
            Logger.error("Handler Crash: #{inspect(status)}/#{inspect(type)}")
            :error
          _ ->
            Logger.debug("Terminating for reason: #{inspect(reason)}")
            :error
        end
      end
    end
  end

end
