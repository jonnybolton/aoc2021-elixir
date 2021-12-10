defmodule Day07 do
  defp parse_file do
    System.argv
    |> File.read!
    |> String.trim
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp get_fuel_required_1(a, b), do: abs(a - b)

  defp get_fuel_required_2(a, b) do
    d = abs(a - b)
    div(d * (d + 1), 2)
  end

  defp get_total_fuel(start_positions, target, fuel_fun) do
    start_positions
    |> Enum.map(&fuel_fun.(&1, target))
    |> Enum.sum
  end

  defp get_possible_targets(start_positions) do
    {min, max} = Enum.min_max(start_positions)
    min..max
  end

  defp get_minimum_total_fuel(start_positions, fuel_fun) do
    start_positions
    |> get_possible_targets
    |> Enum.map(&get_total_fuel(start_positions, &1, fuel_fun))
    |> Enum.min
  end

  def part_one do
    parse_file()
    |> get_minimum_total_fuel(&get_fuel_required_1/2)
  end

  def part_two do
    parse_file()
    |> get_minimum_total_fuel(&get_fuel_required_2/2)
  end
end

Day07.part_one |> IO.puts
Day07.part_two |> IO.puts
