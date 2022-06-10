defmodule ImageFinder do
  use Application

  def start(_type, _args) do
    ImageFinder.Supervisor.start_link()
    ImageSaver.Supervisor.start_link()
    ImageFetcher.Supervisor.start_link()
  end

  def fetch(source_file, target_directory) do
    fetch_multiple([source_file], target_directory)
  end

  def fetch_multiple(files, target_directory) do
    files |> Enum.map(&start_finder(&1, target_directory))
  end

  def start_finder(source_file, target_directory) do
    {:ok, pid} =
      ImageFinder.Supervisor.start_child(
        :"finder-#{Supervisor.count_children(ImageFinder.Supervisor).workers}"
      )

    GenServer.cast(pid, {:fetch, source_file, target_directory})
  end
end
