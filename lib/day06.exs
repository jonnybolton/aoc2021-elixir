defmodule Day06 do
  defp parse_file do
    System.argv
    |> File.read!
    |> String.trim
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp group_by_age(ages) do
    frequency_map = Enum.frequencies(ages)

    0..8
    |> Enum.map(fn n -> Map.get(frequency_map, n, 0) end)
    |> List.to_tuple
  end

  defp advance_one_day({f0, f1, f2, f3, f4, f5, f6, f7, f8}) do
    {f1, f2, f3, f4, f5, f6, f0 + f7, f8, f0}
  end

  defp advance_n_days(age_vector, 0), do: age_vector

  defp advance_n_days(age_vector, n) do
    age_vector
    |> advance_one_day
    |> advance_n_days(n - 1)
  end

  defp get_number_of_fish_after_n_days(ages, n) do
    ages
    |> group_by_age
    |> advance_n_days(n)
    |> Tuple.sum
  end

  def part_one do
    parse_file()
    |> get_number_of_fish_after_n_days(80)
  end

  def part_two do
    parse_file()
    |> get_number_of_fish_after_n_days(256)
  end
end

Day06.part_one |> IO.puts
Day06.part_two |> IO.puts
