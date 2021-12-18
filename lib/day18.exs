defmodule Day18 do
  defp parse_file do
    System.argv
    |> File.read!
    |> String.trim
    |> String.split("\n")
    |> Enum.map(fn line -> line |> String.codepoints |> Enum.map(&parse_digits_to_integers/1) end)
  end

  defp parse_digits_to_integers(char) do
    if Enum.member?(["[", ",", "]"], char), do: char, else: String.to_integer(char)
  end

  defp adjust_depth("[", depth), do: depth + 1
  defp adjust_depth("]", depth), do: depth - 1
  defp adjust_depth(_, depth), do: depth

  defp explode_deeply_nested_pairs(number) do
    case find_explode_index(number) do
      nil -> :continue
      i -> {:halt, do_explode(number, i)}
    end
  end

  defp find_explode_index(number) do
    with_depth =
      number
      |> Enum.map_reduce(0, fn c, depth ->
        new_depth = adjust_depth(c, depth)
        {{c, new_depth}, new_depth}
      end)
      |> elem(0)

    [_ | tail1] = with_depth
    [_ | tail2] = tail1

    Enum.zip([with_depth, tail1, tail2])
    |> Enum.find_index(fn x ->
      case x do
        {{_, d}, {",", d}, {_, d}} when d > 4 -> true
        _ -> false
      end
    end)
  end

  defp do_explode(number, index) do
    a = number |> Enum.at(index)
    b = number |> Enum.at(index + 2)
    {lhs, ["[", _, ",", _, "]" | rhs]} = Enum.split(number, index - 1)
    lhs2 = lhs |> Enum.reverse |> add_to_first_integer(a) |> Enum.reverse
    rhs2 = rhs |> add_to_first_integer(b)
    lhs2 ++ [0] ++ rhs2
  end

  defp add_to_first_integer(list, n) do
    case Enum.find_index(list, &is_integer/1) do
      nil -> list
      i -> List.update_at(list, i, &(&1 + n))
    end
  end

  defp split_large_integers(number) do
    case Enum.find_index(number, fn c -> is_integer(c) and c > 9 end) do
      nil -> :continue
      i -> {:halt, do_split_at(number, i)}
    end
  end

  defp do_split_at(number, index) do
    {lhs, [_ | rhs]} = Enum.split(number, index)
    n = Enum.at(number, index)
    a = div(n, 2)
    b = a + rem(n, 2)
    lhs ++ ["[", a, ",", b, "]"] ++ rhs
  end

  defp reduce(number) do
    case explode_deeply_nested_pairs(number) do
      {:halt, result} -> reduce(result)
      :continue ->
        case split_large_integers(number) do
          {:halt, result} -> reduce(result)
          :continue -> number
        end
    end
  end

  defp add(a, b) do
    ["["] ++ a ++ [","] ++ b ++ ["]"] |> reduce
  end

  defp magnitude(["[", n, "]"]), do: n
  defp magnitude(["[", a, ",", b, "]"]), do: (3 * a) + (2 * b)
  defp magnitude(number) do
    [_ | tail] = number
    [_ | tail2] = tail

    index =
      Enum.zip([number, tail, tail2])
      |> Enum.find_index(fn x ->
        case x do
          {a, ",", b} when is_integer(a) and is_integer(b) -> true
          _ -> false
        end
      end)

    {lhs, temp} = Enum.split(number, index - 1)
    {middle, rhs} = Enum.split(temp, 5)
    magnitude(lhs ++ [magnitude(middle)] ++ rhs)
  end

  def part_one do
    parse_file()
    |> Enum.reduce(fn elem, acc -> add(acc, elem) end)
    |> magnitude
  end

  def part_two do
    numbers = parse_file()

    numbers
    |> Enum.with_index
    |> Task.async_stream(fn {n, i} ->
      numbers
      |> Stream.with_index
      |> Stream.filter(fn {_, j} -> i != j end)
      |> Stream.map(fn {m, _} -> add(n, m) |> magnitude end)
      |> Enum.max
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.max
  end
end

Day18.part_one |> IO.puts
Day18.part_two |> IO.puts
