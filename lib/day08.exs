defmodule Day08 do
  defp parse_file do
    System.argv
    |> File.read!
    |> String.trim
    |> String.split("\n")
    |> Stream.map(&String.split(&1))
    |> Stream.map(&Enum.chunk_every(&1, 10, 11))
    |> Stream.map(&List.to_tuple/1)
  end

  @number_of_segments_for_digit %{
    0 => 6, 1 => 2, 2 => 5, 3 => 5, 4 => 4, 5 => 5, 6 => 6, 7 => 3, 8 => 7, 9 => 6
  }

  @frequency_of_segments_sum_to_digit %{
    42 => 0, 17 => 1, 34 => 2, 39 => 3, 30 => 4, 37 => 5, 41 => 6, 25 => 7, 49 => 8, 45 => 9
  }

  defp calculate_segment_frequency_sum(signal, segment_frequencies) do
    signal
    |> String.to_charlist
    |> Enum.map(&segment_frequencies[&1])
    |> Enum.sum
  end

  defp convert_signal_to_digit(signal, segment_frequencies) do
    frequency_sum = calculate_segment_frequency_sum(signal, segment_frequencies)
    @frequency_of_segments_sum_to_digit[frequency_sum]
  end

  defp get_segment_frequencies(signals) do
    signals
    |> Enum.map(&String.to_charlist/1)
    |> List.flatten
    |> Enum.frequencies
  end

  defp convert_signals_to_digits(signals) do
    segment_frequencies = get_segment_frequencies(signals)
    Enum.map(signals, &convert_signal_to_digit(&1, segment_frequencies))
  end

  defp alphabetize_string(s), do: String.to_charlist(s) |> Enum.sort() |> to_string

  defp alphabetize_strings(ss), do: Enum.map(ss, &alphabetize_string/1)

  def part_one do
    segment_counts = for n <- [1, 4, 7, 8], do: @number_of_segments_for_digit[n]

    parse_file()
    |> Stream.map(&elem(&1, 1))
    |> Stream.flat_map(fn output -> Enum.map(output, &String.length/1) end)
    |> Stream.filter(fn segs -> Enum.any?(segment_counts, &(&1 == segs)) end)
    |> Enum.count
  end

  def part_two do
    parse_file()
    |> Stream.map(fn {signals, output} -> {alphabetize_strings(signals), alphabetize_strings(output)} end)
    |> Stream.map(fn {signals, output} -> {signals, convert_signals_to_digits(signals), output} end)
    |> Stream.map(fn {a, b, c} -> {Map.new(Enum.zip(a, b)), c} end)
    |> Stream.map(fn {lookup, output} -> Enum.map(output, &lookup[&1]) end)
    |> Stream.map(fn [a, b, c, d] -> (1000 * a) + (100 * b) + (10 * c) + d end)
    |> Enum.sum
  end
end

Day08.part_one |> IO.puts
Day08.part_two |> IO.puts
