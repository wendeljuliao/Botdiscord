defmodule Botdiscord.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Botdiscord.Consumer
      # Starts a worker by calling: Botdiscord.Worker.start_link(arg)
      # {Botdiscord.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Botdiscord.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
