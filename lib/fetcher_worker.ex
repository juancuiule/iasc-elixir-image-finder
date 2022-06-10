defmodule ImageFetcher.Worker do
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

  def handle_cast({:fetch, link, target_directory}, state) do
    extension = String.slice(link, -3..-1)

    res = HTTPotion.get(link)

    if HTTPotion.Response.success?(res) do
      res.body |> save(target_directory, extension)
    else
      reason = "Failed to fetch #{link}"
      IO.puts(reason)
    end

    {:noreply, state}
  end

  def save(body, directory, extension) do
    {:ok, childPid} =
      ImageSaver.Supervisor.start_child(
        :"saver-#{Supervisor.count_children(ImageSaver.Supervisor).workers}"
      )

    GenServer.cast(childPid, {:save, body, extension, directory})
  end
end
