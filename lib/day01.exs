defmodule Day01 do
  def parse_file do
    System.argv
    |> File.read!
    |> String.trim
    |> String.split("\n")
    |> Stream.map(&String.to_integer/1)
  end

  def count_increases(data) do
    [_ | data2] = Enum.to_list(data)

    Stream.zip(data, data2)
    |> Stream.filter(fn {a, b} -> (a < b) end)
    |> Enum.count
  end

  def count_sliding_increases(data) do
    [_ | data2] = Enum.to_list(data)
    [_ | data3] = data2

    Stream.zip([data, data2, data3])
    |> Stream.map(&Tuple.sum/1)
    |> count_increases
  end

  def part_one do
    parse_file()
    |> count_increases
  end

  def part_two do
    parse_file()
    |> count_sliding_increases
  end
end

Day01.part_one |> IO.puts
Day01.part_two |> IO.puts
