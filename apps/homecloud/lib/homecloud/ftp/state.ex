defmodule Homecloud.Ftp.Client.State do
    defstruct [:host, :ftp_conn]

    @type t :: %__MODULE__{host: binary(), ftp_conn: pid()}
    @type host :: binary()

    @spec new(host, pid()) :: t()
    def new(ftp_conn, host) do
        %__MODULE__{ftp_conn: ftp_conn, host: host}
    end
end