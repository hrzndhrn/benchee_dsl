defmodule BencheeDsl.Benchee do
  @moduledoc false

  @callback run(map(), keyword()) :: any()

  def run(jobs, config), do: Benchee.run(jobs, config)
end
