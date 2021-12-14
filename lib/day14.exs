defmodule Day14 do
  defp parse_file do
    [template | [_ | rules]] =
      System.argv
      |> File.read!
      |> String.trim
      |> String.split("\n")

    {
      template |> String.to_charlist |> to_pair_frequencies |> group_similar_pairs,
      parse_rules(rules)
    }
  end

  defp to_pair_frequencies(polymer) do
    [_ | tail] = polymer

    polymer
    |> Enum.zip(tail ++ [nil])
    |> Enum.map(fn {a, b} -> {{a, b}, 1} end)
  end

  defp group_similar_pairs(pair_freqs) do
    pair_freqs
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {pair, freqs} -> {pair, Enum.sum(freqs)} end)
  end

  defp parse_rules(input) do
    input
    |> Enum.map(&String.split(&1, " -> "))
    |> Enum.map(fn [<<a, b>>, <<c>>] -> {{a, b}, c} end)
    |> Map.new
  end

  defp apply_rules_to_element_pair({{a, b}, freq}, rules) do
    case Map.get(rules, {a, b}) do
      nil -> [{{a, b}, freq}]
      c -> [{{a, c}, freq}, {{c, b}, freq}]
    end
  end

  defp do_n_iterations(pair_freqs, _, 0), do: pair_freqs
  defp do_n_iterations(pair_freqs, rules, n) do
    pair_freqs
    |> Enum.flat_map(&apply_rules_to_element_pair(&1, rules))
    |> group_similar_pairs
    |> do_n_iterations(rules, n - 1)
  end

  defp get_quantity_difference(pair_freqs) do
    {min_freq, max_freq} =
      pair_freqs
      |> Enum.group_by(fn {{a, _}, _} -> a end, &elem(&1, 1))
      |> Enum.map(fn {_, freqs} -> Enum.sum(freqs) end)
      |> Enum.min_max

    max_freq - min_freq
  end

  defp get_solution_after_n_iterations(n) do
    {pair_frequencies, rules} = parse_file()
    do_n_iterations(pair_frequencies, rules, n) |> get_quantity_difference
  end

  def part_one, do: get_solution_after_n_iterations(10)
  def part_two, do: get_solution_after_n_iterations(40)
end

Day14.part_one |> IO.puts
Day14.part_two |> IO.puts
