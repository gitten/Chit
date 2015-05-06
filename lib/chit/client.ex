defmodule Chit.Client do
  use GenServer
  import Chit.Server

  def start_link(name) do
    IO.puts "Starting Chit client for #{name}"
    GenServer.start_link(
      Chit.Client,
      name,
      name: {:global, {:chit_client, name}}
    )
  end

  def whereis(name) do
    :global.whereis_name({:chit_client, name})
  end

  def init(name) do
    {:ok, name}
  end


  # User API

  def ping_server(client, server_name \\ Chit.Server.default_server) do
    GenServer.call(client, {:ping_server, server_name})
  end

  def say(client, msg, server_name \\ Chit.Server.default_server) do
    GenServer.cast(client, {:say, server_name, msg})
  end


  # GenServer API

  def handle_call({:ping_server, server_name}, _, name) do
    reply = Chit.Server.ping(server_name)
    {:reply, reply, name}
  end

  def handle_cast({:say, server_name, msg}, name) do
    Chit.Server.chat(server_name, name, msg)
    {:noreply, name}
  end

  def handle_cast({:chat, from_name, msg}, name) do
    IO.puts "#{from_name}> #{msg}"
    {:noreply, name}
  end
  
  
end