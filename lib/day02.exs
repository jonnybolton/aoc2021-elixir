defmodule Day02 do
  def parse_file do
    System.argv
    |> File.read!
    |> String.trim
    |> String.split("\n")
    |> Stream.map(&String.split/1)
    |> Stream.map(fn [dir, dist] -> [dir, String.to_integer(dist)] end)
  end

  def apply_command(command, {hpos, depth}) do
    case command do
      ["forward", units] -> {hpos + units, depth}
      ["down", units] -> {hpos, depth + units}
      ["up", units] -> {hpos, depth - units}
    end
  end

  def apply_command_with_aim(command, {hpos, depth, aim}) do
    case command do
      ["forward", units] -> {hpos + units, depth + (aim * units), aim}
      ["down", units] -> {hpos, depth, aim + units}
      ["up", units] -> {hpos, depth, aim - units}
    end
  end

  def part_one do
    parse_file()
    |> Enum.reduce({0, 0}, &apply_command/2)
    |> Tuple.product()
  end

  def part_two do
    parse_file()
    |> Enum.reduce({0, 0, 0}, &apply_command_with_aim/2)
    |> Tuple.delete_at(2)
    |> Tuple.product()
  end
end

Day02.part_one |> IO.puts()
Day02.part_two |> IO.puts()
