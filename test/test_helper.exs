Dynamo.under_test(CORSEcho.Dynamo)
Dynamo.Loader.enable
ExUnit.start

defmodule CORSEcho.TestCase do
  use ExUnit.CaseTemplate

  # Enable code reloading on test cases
  setup do
    Dynamo.Loader.enable
    :ok
  end
end
