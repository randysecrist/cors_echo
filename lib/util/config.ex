defmodule API.Config do
  # SSL Config
  def get_protocol(), do:
    :proplists.get_value(:protocol, get_env(:network))

  def get_bind_address(), do:
    :proplists.get_value(:bind, get_env(:network))

  def get_num_acceptors(), do:
    :proplists.get_value(:acceptors, get_env(:network))

  def get_ssl_cacertfile(), do:
    :proplists.get_value(:cacertfile, get_env(:ssl))

  def get_ssl_certfile(), do:
    :proplists.get_value(:certfile, get_env(:ssl))

  def get_ssl_keyfile(), do:
    :proplists.get_value(:keyfile, get_env(:ssl))

  # Utility Funs
  def get(), do:
    :application.get_all_env(:cors_echo)

  def get_logger_config(), do:
    Logger.Config.__data__()

  # Internal
  defp get_env(key) do
    {_, value} = :application.get_env(:cors_echo, key)
    value
  end
  defp system_env(value, default \\ nil) do
    case value do
      {:system, env_var} ->
        case System.get_env(env_var) do
          nil -> default
          val -> val
        end
      {:system, env_var, preconfigured_default} ->
        case System.get_env(env_var) do
          nil -> preconfigured_default
          val -> val
        end
      nil ->
        default
      val ->
        val
    end
  end
end
