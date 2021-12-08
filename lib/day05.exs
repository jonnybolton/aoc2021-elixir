defmodule Day05 do
  defp parse_file do
    System.argv
    |> File.read!
    |> String.trim
    |> String.split("\n")
    |> Enum.map(fn s -> String.split(s, [" -> ", ","]) end)
    |> Enum.map(fn ns -> Enum.map(ns, &String.to_integer/1) end)
    |> Enum.map(&List.to_tuple/1)
  end

  defp get_points_on_line({x1, y1, x1, y1}) do
    [{x1, y1}]
  end

  defp get_points_on_line({x1, y1, x2, y1}) when x1 < x2 do
    [{x1, y1} | get_points_on_line({x1 + 1, y1, x2, y1})]
  end

  defp get_points_on_line({x1, y1, x2, y1}) do
    get_points_on_line({x2, y1, x1, y1})
  end

  defp get_points_on_line({x1, y1, x1, y2}) when y1 < y2 do
    [{x1, y1} | get_points_on_line({x1, y1 + 1, x1, y2})]
  end

  defp get_points_on_line({x1, y1, x1, y2}) do
    get_points_on_line({x1, y2, x1, y1})
  end

  defp get_points_on_line(_), do: []

  defp get_points_on_line({x1, y1, x2, y2}, :include_diagonals) when x1 < x2 and y1 < y2 do
    [{x1, y1} | get_points_on_line({x1 + 1, y1 + 1, x2, y2}, :include_diagonals)]
  end

  defp get_points_on_line({x1, y1, x2, y2}, :include_diagonals) when x1 > x2 and y1 > y2 do
    get_points_on_line({x2, y2, x1, y1}, :include_diagonals)
  end

  defp get_points_on_line({x1, y1, x2, y2}, :include_diagonals) when x1 < x2 and y1 > y2 do
    [{x1, y1} | get_points_on_line({x1 + 1, y1 - 1, x2, y2}, :include_diagonals)]
  end

  defp get_points_on_line({x1, y1, x2, y2}, :include_diagonals) when x1 > x2 and y1 < y2 do
    get_points_on_line({x2, y2, x1, y1}, :include_diagonals)
  end

  defp get_points_on_line(line, :include_diagonals), do: get_points_on_line(line)

  defp count_overlapped_points(lines, fun) do
    lines
    |> Enum.flat_map(fun)
    |> Enum.frequencies
    |> Enum.count(fn {_, frequency} -> frequency > 1 end)
  end

  def part_one do
    parse_file()
    |> count_overlapped_points(&get_points_on_line/1)
  end

  def part_two do
    parse_file()
    |> count_overlapped_points(&get_points_on_line(&1, :include_diagonals))
  end
end

Day05.part_one |> IO.puts
Day05.part_two |> IO.puts
