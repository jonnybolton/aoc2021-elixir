defmodule Day13 do
  defp parse_file do
    System.argv
    |> File.read!
    |> String.trim
    |> String.split("\n")
    |> Enum.split_while(fn line -> String.length(line) > 0 end)
    |> (fn {points, [_ | folds]} -> {parse_points(points), parse_folds(folds)} end).()
  end

  defp parse_points(points) do
    points
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn [x, y] -> {String.to_integer(x), String.to_integer(y)} end)
  end

  defp parse_folds(folds) do
    folds
    |> Enum.map(&String.split(&1, [" ", "="]))
    |> Enum.map(fn [_, _, axis, position] -> {parse_axis(axis), String.to_integer(position)} end)
  end

  defp parse_axis("x"), do: :x
  defp parse_axis("y"), do: :y

  defp apply_fold(point, fold) do
    case {point, fold} do
      {{x, y}, {:x, position}} when x > position -> {position - (x - position), y}
      {{x, y}, {:y, position}} when y > position -> {x, position - (y - position)}
      _ -> point
    end
  end

  defp draw(points) do
    max_x = Enum.max_by(points, &elem(&1, 0)) |> elem(0)
    max_y = Enum.max_by(points, &elem(&1, 1)) |> elem(1)
    buffer = List.duplicate(List.duplicate(".", max_x + 1), max_y + 1)

    points
    |> Enum.reduce(buffer, fn {x, y}, b -> List.replace_at(b, y, List.replace_at(Enum.at(b, y), x, "#")) end)
    |> Enum.map(&to_string/1)
    |> List.foldr("", fn s1, s2 -> s1 <> "\n" <> s2 end)
  end

  def part_one do
    {points, [fold | _]} = parse_file()

    points
    |> Enum.map(&apply_fold(&1, fold))
    |> Enum.uniq
    |> Enum.count
  end

  def part_two do
    {points, folds} = parse_file()

    Enum.reduce(folds, points, fn fold, ps -> Enum.map(ps, &apply_fold(&1, fold)) end)
    |> Enum.uniq
    |> draw
  end
end

Day13.part_one |> IO.puts
Day13.part_two |> IO.puts
