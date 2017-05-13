defmodule Sidekiq.Worker do
  @moduledoc false

  import :jiffy, only: [encode: 1]
  import :eredis, only: [q: 2]

  @default_queue "default"

  def enqueue(redis, worker, args \\ [], options \\ Map.new) do
    payload = payload worker, args, options
    json = encode {Map.to_list(payload)}
    q redis, ["LPUSH", queue_key(options[:queue]), json]
  end

  defp payload(worker, args, options) do
    worker
    |> payload_defaults(args, options)
    |> Map.merge(Map.new(options))
  end

  defp payload_defaults(worker, args, _options) do
    Map.new [class: worker, args: args, queue: @default_queue]
  end

  defp queue_key(queue) do
    "queue:#{queue}"
  end
end
