defmodule Homecloud.Ftp.Client do
  use GenServer

  alias Homecloud.Ftp.Client.State
  alias Homecloud.Ftp.File
  alias Homecloud.Ftp.Directory

  # Public API
  def is_connected?(host) do
    case :global.whereis_name(host) do
      :undefined -> false
      client_pid ->
        DynamicSupervisor.which_children(Homecloud.Ftp.Supervisor)
        |> Enum.any?(fn
            {:undefined, ^client_pid, :worker, [Homecloud.Ftp.Client]} -> true
          _ -> false
        end)
    end
  end

  @spec client!(State.host()) :: pid()
  def client!(host) do
    case :global.whereis_name(host) do
      :undefined ->
        raise "unknown_fpt_client"

      client_pid ->
        existing =
          DynamicSupervisor.which_children(Homecloud.Ftp.Supervisor)
          |> Enum.any?(fn
            {:undefined, ^client_pid, :worker, [Homecloud.Ftp.Client]} -> true
            _ -> false
          end)

        if not existing do
          raise "stale_fpt_client"
        else
          client_pid
        end
    end
  end

  @spec dir(pid(), binary()) :: [binary()]
  def dir(pid, path), do: GenServer.call(pid, {:dir, path})

  @spec fetch(pid(), binary()) :: [binary()]
  def fetch(pid, path), do: GenServer.call(pid, {:fetch, path})

  # Supervisor spec
  def connect(host) do
    DynamicSupervisor.start_child(Homecloud.Ftp.Supervisor, {__MODULE__, host})
  end

  @spec start_link(binary) :: {:ok, pid()}
  def start_link(host) do
    GenServer.start_link(__MODULE__, [host], name: {:global, host})
  end

  # Callbacks

  @impl true
  def init([host] = params) do
    # TODO Username and Password should be dynamically loaded
    with {:ok, pid} <- :ftp.open(String.to_charlist(host), debug: :debug, mode: :passive),
         :ok <- :ftp.user(pid, 'homecloud', '1234') do
      {:ok, State.new(pid, host)}
    else
      e -> {:stop, e}
    end
  end

  @impl true
  def handle_call({:dir, path}, _from, %State{host: host, ftp_conn: conn} = state) do
    with {:ok, listing} <- :ftp.ls(conn, path |> String.to_charlist()) do
      {:reply, parse_ftp_listing(listing), state}
    else
      _ -> {:reply, [], state}
    end
  end

  def handle_call({:fetch, path}, _from, state) do
    {:reply, "", state}
  end

  def parse_ftp_listing([]), do: []
  def parse_ftp_listing('\r\n'), do: []

  def parse_ftp_listing(crlf_listing) do
    crlf_listing
    |> List.foldl(
      [],
      fn
        10, [ht | acc] ->
          case {ht, acc} do
            {[13 | t], _} -> [[] | [t | acc]]
            _ -> [[] | [ht | acc]]
          end

        item, [head | acc] ->
          [[item | head] | acc]

        item, [] ->
          [[item]]
      end
    )
    |> Enum.filter(&(not Enum.empty?(&1)))
    |> Enum.map(fn line -> line |> Enum.reverse() |> String.Chars.to_string() |> to_file() end)
    |> Enum.reverse()
  end

  @doc """
  # dr-x------   3 user group            0 May 19 21:43 foo
  """
  def to_file(line) do
    case String.split(line, ~r{\s+}, parts: 9) do
      [flags, _, _user, _group, size, month, day, hhmm, name] ->
        if String.starts_with?(flags, "d") do
          %Directory{path: name, size: String.to_integer(size), ctime: "#{month} #{day} #{hhmm}"}
        else
          %File{path: name, size: String.to_integer(size), ctime: "#{month} #{day} #{hhmm}"}
        end

      _ ->
        raise "Invalid data format"
    end
  end
end
