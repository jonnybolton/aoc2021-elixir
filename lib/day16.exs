defmodule Day16 do
  defp parse_file do
    System.argv
    |> File.read!
    |> String.trim
    |> String.codepoints
    |> Enum.flat_map(&convert_to_bits/1)
  end

  defp convert_to_bits(hex_digit) do
    hex_digit
    |> String.to_integer(16)
    |> Integer.digits(2)
    |> pad_to_4_bits
  end

  defp pad_to_4_bits([a, b, c, d]), do: [a, b, c, d]
  defp pad_to_4_bits(bit_array), do: pad_to_4_bits([0 | bit_array])

  defp bits_to_integer(digits, n) do
    {integer, rest} = Enum.split(digits, n)
    {bits_to_integer(integer), rest}
  end

  defp bits_to_integer(digits) do
    digits
    |> Enum.reverse
    |> Enum.reduce({0, 1}, fn x, {total, k} -> {total + (x * k), k * 2} end)
    |> elem(0)
  end

  defp parse_packet(packet) do
    {header, rest} = parse_header(packet)
    {payload, rest2} =
      case header[:type] do
        4 -> parse_number(rest)
        _ -> parse_operator(rest)
      end
    {header ++ [payload: payload], rest2}
  end

  defp parse_header(packet) do
    {version, rest} = bits_to_integer(packet, 3)
    {type, rest2} = bits_to_integer(rest, 3)
    {[version: version, type: type], rest2}
  end

  defp parse_number(input) do
    {bits, tail} = do_parse_number(input)
    {bits |> Enum.reverse |> bits_to_integer, tail}
  end

  defp do_parse_number(input, digits \\ []) do
    case input do
      [1, b1, b2, b3, b4 | tail] -> do_parse_number(tail, [b4, b3, b2, b1 | digits])
      [0, b1, b2, b3, b4 | tail] -> {[b4, b3, b2, b1 | digits], tail}
    end
  end

  defp parse_operator(input) do
    {config, rest} = parse_operator_config(input)
    case config[:type] do
      :bit_length ->
        {packet_bits, rest2} = Enum.split(rest, config[:value])
        {parse_packets_until_empty(packet_bits), rest2}
      :packet_count ->
        parse_n_packets(rest, config[:value])
    end
  end

  defp parse_packets_until_empty(input, packets \\ [])
  defp parse_packets_until_empty([], packets), do: Enum.reverse(packets)
  defp parse_packets_until_empty(input, packets) do
    {packet, rest} = parse_packet(input)
    parse_packets_until_empty(rest, [packet | packets])
  end

  defp parse_n_packets(input, n, packets \\ [])
  defp parse_n_packets(input, 0, packets), do: {Enum.reverse(packets), input}
  defp parse_n_packets(input, n, packets) do
    {packet, rest} = parse_packet(input)
    parse_n_packets(rest, n - 1, [packet | packets])
  end

  defp parse_operator_config(input) do
    case input do
      [0 | tail] ->
        {bit_length, rest} = bits_to_integer(tail, 15)
        {[type: :bit_length, value: bit_length], rest}
      [1 | tail] ->
        {packet_count, rest} = bits_to_integer(tail, 11)
        {[type: :packet_count, value: packet_count], rest}
    end
  end

  defp get_version_sum(packet) do
    subpacket_version_sum =
      case packet[:type] do
        4 -> 0
        _ -> packet[:payload] |> Enum.reduce(0, fn subpacket, total -> total + get_version_sum(subpacket) end)
      end

    packet[:version] + subpacket_version_sum
  end

  defp evaluate(packet) do
    case packet[:type] do
      0 -> packet[:payload] |> Enum.reduce(0, fn subpacket, total -> evaluate(subpacket) + total end)
      1 -> packet[:payload] |> Enum.reduce(1, fn subpacket, total -> evaluate(subpacket) * total end)
      2 -> packet[:payload] |> Enum.map(&evaluate/1) |> Enum.min
      3 -> packet[:payload] |> Enum.map(&evaluate/1) |> Enum.max
      4 -> packet[:payload]
      5 ->
        [a, b] = packet[:payload]
        if evaluate(a) > evaluate(b), do: 1, else: 0
      6 ->
        [a, b] = packet[:payload]
        if evaluate(a) < evaluate(b), do: 1, else: 0
      7 ->
        [a, b] = packet[:payload]
        if evaluate(a) == evaluate(b), do: 1, else: 0
    end
  end

  def part_one do
    parse_file()
    |> parse_packet
    |> elem(0)
    |> get_version_sum
  end

  def part_two do
    parse_file()
    |> parse_packet
    |> elem(0)
    |> evaluate
  end
end

Day16.part_one |> IO.puts
Day16.part_two |> IO.puts
