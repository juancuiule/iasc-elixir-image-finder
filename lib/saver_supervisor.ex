defmodule ImageSaver.Supervisor do
  use DynamicSupervisor

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(child_name) do
    spec = {ImageSaver.Worker, {child_name}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
