defmodule Gophex.GophexTest do
  use ExUnit.Case, async: false
  
  test "Supervisor is spawned when server is started" do
    supervisor_pid = Gophex.Supervisor.start("", "")
    assert is_pid(Process.whereis(Gophex.Supervisor))
  end

  test "can establish a TCP connection with Gophex" do
    worker_pid = spawn fn -> Gophex.Worker.accept(4040) end
    assert {:ok, socket} = :gen_tcp.connect('0.0.0.0', 4040, [:binary, packet: 0, active: false, reuseaddr: true])
    :ok = :gen_tcp.close(socket)
    Process.exit(worker_pid, :kill)
  end

  test "Sending empty string brings back file list on server" do
    Gophex.Agent.start_link({})
    assert is_list(Gophex.Agent.get(:main, :menu))
  end

  test "All command sends all files currently on Gopher server" do
    Gophex.Agent.start_link({})
    file_list = Gophex.Agent.get(:main, :all)    
    assert is_map(file_list)
    assert map_size(file_list) > length(Gophex.Agent.get(:main, :menu))
  end

  test "Get command sends requested file" do
    Gophex.Agent.start_link({})
    file_list = Gophex.Agent.get(:main, :get, "gopher_facts.txt")
    assert Map.has_key?(file_list, :__struct__)
    assert file_list.data == File.stat(file_list.path)
  end
end
