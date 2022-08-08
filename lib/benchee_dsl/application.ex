defmodule BencheeDsl.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Kino.SmartCell.register(BencheeDsl.SmartCell)

    children = [
      BencheeDsl.Server
    ]

    opts = [strategy: :one_for_one, name: BencheeDsl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
