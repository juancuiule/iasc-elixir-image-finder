defmodule ImageSaver.Worker do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def child_spec({name}) do
    %{id: name, start: {__MODULE__, :start_link, [name]}, type: :worker}
  end

  def init(:ok) do
    {:ok, []}
  end

  def handle_cast({:save, body, extension, target_directory}, state) do
    File.write!("#{target_directory}/#{digest(body)}.#{extension}", body)

    {:noreply, state}
  end

  def digest(body) do
    :crypto.hash(:md5, body) |> Base.encode16()
  end
end
