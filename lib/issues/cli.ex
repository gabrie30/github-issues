defmodule Issues.CLI do

  @default_count 4

  def run(argv) do
    argv
     |> parse_args
     |> process
     |> decode_response
  end

  def process(:help) do
    IO.puts "NO halp today"
    System.halt(0)
  end

  def process {user, project, count} do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> sort_into_ascending_order
    |> Enum.take(count)
  end

  def sort_into_ascending_order(list_of_issues) do
    Enum.sort list_of_issues,
      fn i1, i2 ->
        Map.get(i1, "created_at") <= Map.get(i2, "created_at")
      end
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     aliases: [h: :help])
    case parse do
      { [ help: true ], _, _ }            -> :help
      { _, [ user, project, count ],  _ } -> { user, project, String.to_integer count }
      { _, [ user, project], _ }          -> { user, project, @default_count }
      _                                   -> :help
    end
  end

  def decode_response({:ok, body}), do: body
  def decode_response({:error, body}) do
    IO.puts "ERROR FETCHING FROM GH"
    System.halt(2)
  end
end
