defmodule Day12 do
  defp parse_file do
    System.argv
    |> File.read!
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.map(&List.to_tuple/1)
  end

  defp create_lookup_table(input) do
    input ++ Enum.map(input, fn {a, b} -> {b, a} end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  defp mark_as_visited(cave, visited) do
    if cave == String.downcase(cave), do: [cave | visited], else: visited
  end

  defp count_unique_paths(lookup, start, finish, cave_filter, visited \\ [], total \\ 0)

  defp count_unique_paths(_, cave, cave, _, _, _), do: 1

  defp count_unique_paths(lookup, start, finish, cave_filter, visited, total) do
    updated_visited = mark_as_visited(start, visited)

    lookup[start]
    |> Enum.filter(&cave_filter.(&1, updated_visited))
    |> Enum.reduce(total, fn cave, acc ->
      acc + count_unique_paths(lookup, cave, finish, cave_filter, updated_visited)
    end)
  end

  defp can_enter_cave_1(cave, visited), do: not Enum.member?(visited, cave)

  defp contains_duplicates(enum) do
    Enum.count(Enum.uniq(enum)) != Enum.count(enum)
  end

  defp can_enter_cave_2(cave, visited) do
    case cave do
      "start" -> not Enum.member?(visited, cave)
      "end" -> not Enum.member?(visited, cave)
      _ -> (not Enum.member?(visited, cave)) or (not contains_duplicates(visited))
    end
  end

  def part_one do
    parse_file()
    |> create_lookup_table
    |> count_unique_paths("start", "end", &can_enter_cave_1/2)
  end

  def part_two do
    parse_file()
    |> create_lookup_table
    |> count_unique_paths("start", "end", &can_enter_cave_2/2)
  end
end

Day12.part_one |> IO.puts
Day12.part_two |> IO.puts
