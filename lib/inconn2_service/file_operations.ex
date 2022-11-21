defmodule Inconn2Service.FileOperations do
  def read_file_without_extra_values(content) do
    open_file_stream(content)
    |> CSV.decode!(seperator: ?,, headers: true)
    |> Enum.to_list()
    |> IO.inspect()
  end

  defp open_file_stream(content) do
    Path.expand(content.path) |> File.stream!([:trim_bom])
  end
end
