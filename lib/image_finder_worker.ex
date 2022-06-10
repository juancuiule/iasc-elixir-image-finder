defmodule ImageFinder.Worker do
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

  def handle_cast({:fetch, source_file, target_directory}, state) do
    IO.puts("Fetching images from #{source_file}")

    content = File.read!(source_file)
    regexp = ~r/http(s?)\:.*?\.(png|jpg|gif)/

    Regex.scan(regexp, content)
    |> Enum.map(&List.first/1)
    |> Enum.map(&fetch_link(&1, target_directory))

    {:noreply, state}
  end

  def fetch_link(link, target_directory) do
    {:ok, pid} =
      ImageFetcher.Supervisor.start_child(
        :"fetcher-#{Supervisor.count_children(ImageFetcher.Supervisor).workers}"
      )

    GenServer.cast(pid, {:fetch, link, target_directory})
  end
end
