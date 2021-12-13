defmodule Day09 do
  defp parse_file do
    heights =
      System.argv
      |> File.read!
      |> String.trim
      |> String.split("\n")
      |> Enum.map(fn line -> String.codepoints(line) |> Enum.map(&String.to_integer/1) end)

      %{
        heights: heights |> List.flatten |> :array.from_list,
        width: heights |> List.first |> Enum.count,
        height: heights |> Enum.count,
      }
  end

  defp get_height({x, y}, data), do: :array.get((data[:width] * y) + x, data[:heights])

  defp set_height({x, y}, val, data) do
    Map.replace!(data, :heights, :array.set((data[:width] * y) + x, val, data[:heights]))
  end

  defp exchange_height(coord, val, data), do: {get_height(coord, data), set_height(coord, val, data)}

  defp get_neighbor_coords(data, {x, y}) do
    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    |> Enum.map(fn {ox, oy} -> {x + ox, y + oy} end)
    |> Enum.filter(fn {x, y} -> x >= 0 and x < data[:width] and y >= 0 and y < data[:height] end)
  end

  defp get_low_point_or_nil(data, coord) do
    this_height = get_height(coord, data)

    get_neighbor_coords(data, coord)
    |> Enum.map(&get_height(&1, data))
    |> Enum.filter(&(&1 <= this_height))
    |> Enum.empty?
    |> if(do: this_height, else: nil)
  end

  defp get_low_point_coords(data) do
    for y <- 0..data[:height] - 1, x <- 0..data[:width] - 1, get_low_point_or_nil(data, {x, y}) != nil do
      {x, y}
    end
  end

  defp get_low_point_risk_levels(data) do
    data
    |> get_low_point_coords
    |> Enum.map(fn coord -> get_height(coord, data) + 1 end)
  end

  defp get_basin_size(coord, data) do
    do_get_basin_size(coord, data)
    |> elem(1)
  end

  defp do_get_basin_size(coord, data) do
    case exchange_height(coord, 9, data) do
      {9, new_data} -> {new_data, 0}
      {_, new_data} ->
        get_neighbor_coords(new_data, coord)
        |> Enum.reduce({new_data, 1}, fn neighbor, {d, s} ->
          {dd, inner_size} = do_get_basin_size(neighbor, d)
          {dd, s + inner_size}
        end)
    end
  end

  defp get_basin_sizes(heights) do
    heights
    |> get_low_point_coords
    |> Enum.map(&get_basin_size(&1, heights))
  end

  def part_one do
    parse_file()
    |> get_low_point_risk_levels
    |> Enum.sum
  end

  def part_two do
    parse_file()
    |> get_basin_sizes()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product
  end
end

Day09.part_one |> IO.puts
Day09.part_two |> IO.puts
