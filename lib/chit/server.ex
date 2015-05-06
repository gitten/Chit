defmodule Chit.Server do
  use GenServer

  @chit_server :chit_server

  def start_link(name \\ default_server) do
    IO.puts "Starting Chit server for #{name}"
    GenServer.start_link(
      Chit.Server, name,
      name: {:global, {:chit_server, name}}
    )
  end

  def whereis(name \\ default_server) do
    :global.whereis_name({:chit_server, name})
  end


  # Client API

  def default_server do
    @chit_server
  end

  def ping(name \\ @chit_server) do
    GenServer.call(whereis(name), :ping)
  end

  # Chit.Server.chat(server_name, self, name, msg)
  def chat(server_name, client_name, msg) do
    GenServer.cast(whereis(server_name), {:chat, client_name, msg})
  end


  # GenServer Callbacks

  def handle_call(:ping, _, name) do
    {:reply, :pong, name}
  end

  def handle_cast({:chat, from_name, msg}, name) do
    # send message to all here
    is_client = fn {type, _name} -> type == :chit_client end
    for {_, to_name} <- Enum.filter(:global.registered_names, is_client) do
      GenServer.cast(Chit.Client.whereis(to_name), {:chat, from_name, msg})
    end
    {:noreply, name}
  end



end