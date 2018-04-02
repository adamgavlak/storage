defmodule Storage.Adapter do
  @callback put(Storage.File.t, String.t) :: Storage.File.t
  @callback exists?(String.t) :: true | false
  @callback url(String.t) :: String.t
  @callback delete(String.t) :: :ok
end
