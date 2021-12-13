defmodule Day11 do
  defp parse_file do
    energy =
      System.argv
      |> File.read!
      |> String.trim
      |> String.split("\n")
      |> Enum.map(fn line -> String.codepoints(line) |> Enum.map(&String.to_integer/1) end)
      |> Enum.with_index
      |> Enum.map(fn {es, y} -> es |> Enum.with_index |> Enum.map(fn {e, x} -> {e, {x, y}} end) end)

    %{
      energy: energy |> List.flatten |> :array.from_list,
      width: energy |> List.first |> Enum.count,
      height: energy |> Enum.count,
    }
  end

  defp get_energy({x, y}, data), do: elem(:array.get((data[:width] * y) + x, data[:energy]), 0)

  defp set_energy({x, y}, val, data) do
    Map.replace!(data, :energy, :array.set((data[:width] * y) + x, {val, {x, y}}, data[:energy]))
  end

  defp get_neighbor_coords(data, {x, y}) do
    [{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}]
    |> Enum.map(fn {ox, oy} -> {x + ox, y + oy} end)
    |> Enum.filter(fn {x, y} -> x >= 0 and x < data[:width] and y >= 0 and y < data[:height] end)
  end

  defp get_high_energy_coords(data) do
    data[:energy]
    |> :array.to_list
    |> Enum.filter(fn {energy, _} -> is_integer(energy) and energy > 9 end)
    |> Enum.map(&elem(&1, 1))
  end

  defp increase_energy_uniformly(data) do
    Map.update!(data, :energy, fn grid -> :array.map(fn _, {e, c} -> {e + 1, c} end, grid) end)
  end

  defp flash_at_coords(data, []), do: data
  defp flash_at_coords(data, [c | cs]) do
    set_energy(c, :flashed, data)
    |> flash_at_coords(cs)
  end

  defp increment_coord(data, coord) do
    previous_energy = get_energy(coord, data)
    case previous_energy do
      :flashed -> data
      _ ->
        set_energy(coord, previous_energy + 1, data)
    end
  end

  defp increment_neighbors(data, []), do: data
  defp increment_neighbors(data, [c | cs]) do
    data
    |> get_neighbor_coords(c)
    |> Enum.reduce(data, fn nc, d -> increment_coord(d, nc) end)
    |> increment_neighbors(cs)
  end

  defp apply_flashes(data, total \\ 0) do
    high_energy_coords = get_high_energy_coords(data)
    case high_energy_coords do
      [] -> {data, total}
      _ ->
        data
        |> flash_at_coords(high_energy_coords)
        |> increment_neighbors(high_energy_coords)
        |> apply_flashes(total + Enum.count(high_energy_coords))
    end
  end

  defp reset_flashed_octopus({:flashed, coord}), do: {0, coord}
  defp reset_flashed_octopus(x), do: x

  defp reset_flashed_octopuses(data) do
    Map.update!(data, :energy,
      fn _ -> :array.map(fn _, x -> reset_flashed_octopus(x) end, data[:energy]) end
    )
  end

  defp apply_rules(data) do
    {updated_data, number_of_flashes} =
      data
      |> increase_energy_uniformly
      |> apply_flashes

    {number_of_flashes, reset_flashed_octopuses(updated_data)}
  end

  defp do_n_iterations(data, n, flashes \\ 0)

  defp do_n_iterations(data, 0, flashes), do: {data, flashes}

  defp do_n_iterations(data, n, flashes) do
    {new_flashes, updated_data} = apply_rules(data)
    do_n_iterations(updated_data, n - 1, flashes + new_flashes)
  end

  defp get_time_of_first_simultaneous_flash(data, time \\ 0) do
    {new_data, flashes} = do_n_iterations(data, 1)
    if flashes == new_data[:width] * new_data[:height] do
      time + 1
    else
      get_time_of_first_simultaneous_flash(new_data, time + 1)
    end
  end

  def part_one do
    parse_file()
    |> do_n_iterations(100)
    |> elem(1)
  end

  def part_two do
    parse_file()
    |> get_time_of_first_simultaneous_flash
  end
end

Day11.part_one |> IO.puts
Day11.part_two |> IO.puts
