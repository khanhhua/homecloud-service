defmodule Homecloud.Ftp.File do
    defstruct [:path, :size, :ctime]
end

defmodule Homecloud.Ftp.Directory do
    defstruct [:path, :size, :ctime]
end