defmodule Day03 do
  defp parse_file do
    System.argv
    |> File.read!
    |> String.trim
    |> String.split("\n")
    |> Stream.map(&String.to_charlist/1)
  end

  defp calculate_gamma_rate(binary_numbers) do
    count_digits = fn binary_number, acc ->
      Enum.zip(binary_number, acc)
      |> Enum.map(fn {n, a} -> if n == ?1 do a + 1 else a - 1 end end)
    end

    binary_numbers
    |> Enum.reduce(List.duplicate(0, 12), count_digits)
    |> Enum.map(fn a -> if a >= 0 do ?1 else ?0 end end)
  end

  defp calculate_power_consumption(binary_numbers) do
    gamma_rate = calculate_gamma_rate(binary_numbers)
    epsilon_rate = invert_binary_number(gamma_rate)
    to_base_10(gamma_rate) * to_base_10(epsilon_rate)
  end

  defp to_base_10(binary_number) do
    binary_number
    |> to_string
    |> Integer.parse(2)
    |> elem(0)
  end

  defp invert_binary_digit(binary_digit) do
    case binary_digit do
      ?1 -> ?0
      ?0 -> ?1
    end
  end

  defp invert_binary_number(binary_number) do
    binary_number
    |> Enum.map(&invert_binary_digit/1)
  end

  defp calculate_rating(binary_numbers, rule) do
    do_calculate_rating(binary_numbers, rule, 0)
  end

  defp do_calculate_rating([binary_number], _rule, _char_index) do
    to_base_10(binary_number)
  end

  defp do_calculate_rating(binary_numbers, rule, char_index) do
    binary_numbers
    |> filter_numbers_with_rule(rule, char_index)
    |> do_calculate_rating(rule, char_index + 1)
  end

  defp get_most_common_char(binary_numbers, char_index) do
    binary_numbers
    |> calculate_gamma_rate
    |> Enum.at(char_index)
  end

  defp filter_numbers_with_rule(binary_numbers, rule, char_index) do
    most_common_char = get_most_common_char(binary_numbers, char_index)

    binary_numbers
    |> Enum.filter(fn n -> rule.(Enum.at(n, char_index), most_common_char) end)
  end

  defp calculate_life_support_rating(binary_numbers) do
    oxygen_generator_rating = calculate_rating(binary_numbers, &==/2)
    co2_scrubber_rating = calculate_rating(binary_numbers, &!=/2)
    oxygen_generator_rating * co2_scrubber_rating
  end

  def part_one do
    parse_file()
    |> calculate_power_consumption
  end

  def part_two do
    parse_file()
    |> Enum.to_list
    |> calculate_life_support_rating
  end
end

Day03.part_one |> IO.puts
Day03.part_two |> IO.puts
