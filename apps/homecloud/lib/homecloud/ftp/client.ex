defmodule Homecloud.Ftp.Client do
  use GenServer

  alias Homecloud.Ftp.Client.State
  alias Homecloud.Ftp.File
  alias Homecloud.Ftp.Directory

  # Public API
  def is_connected?(host) do
    case :global.whereis_name(host) do
      :undefined ->
        false

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
  def connect(host, username, password) do
    case DynamicSupervisor.start_child(
          Homecloud.Ftp.Supervisor,
          {__MODULE__, [host, username, password]}
        )
    do
      {:ok, _} = result -> result
      {:error, {:already_started, pid}} -> {:ok, pid}
      e -> e
    end
  end

  @spec start_link(binary) :: {:ok, pid()}
  def start_link([host| _] = args) do
    GenServer.start_link(__MODULE__, args, name: {:global, host})
  end

  # Callbacks

  @impl true
  def init([host, username, password]) do
    with {:ok, pid} <- ftp_open(host),
         :ok <- :ftp.user(pid, username |> String.to_charlist(), password |> String.to_charlist()) do
      {:ok, State.new(pid, host)}
    else
      e -> {:stop, e}
    end
  end

  defp ftp_open(host) when is_binary(host) do
    :ftp.open(String.to_charlist(host), mode: :active)
  end

  defp ftp_open({_, _, _, _} = host) do
    :ftp.open(host, mode: :active)
  end

  defp ftp_open({_, _, _, _, _, _, _, _} = host) do
    :ftp.open(host, ipfamily: :inet6, mode: :active)
  end

  @impl true
  def handle_call({:dir, path}, _from, %State{host: host, ftp_conn: conn} = state) do
    with {:ok, listing} <- :ftp.ls(conn, path |> String.to_charlist()) do
      entries =
        listing
        |> parse_ftp_listing()
        |> Enum.map(fn %{path: child_path} = p -> %{p | path: path <> child_path} end)

      {:reply, entries, state}
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
