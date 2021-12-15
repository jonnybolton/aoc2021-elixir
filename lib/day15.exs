defmodule Day15 do
  defp parse_file do
    risks =
      System.argv
      |> File.read!
      |> String.trim
      |> String.split("\n")
      |> Enum.map(fn line -> String.codepoints(line) |> Enum.map(&String.to_integer/1) end)

    %{
      risks: risks |> List.flatten |> :array.from_list,
      width: risks |> List.first |> Enum.count,
      height: risks |> Enum.count,
    }
  end

  defp get_val_from_grid({x, y}, width, grid), do: :array.get((width * y) + x, grid)
  defp set_val_in_grid({x, y}, value, width, grid), do: :array.set((width * y) + x, value, grid)

  defp manhattan_distance({x0, y0}, {x1, y1}), do: abs(x1 - x0) + abs(y1 - y0)

  defp create_distance_grid(data, start_coord, value_at_start_coord) do
    distances = :array.new([{:size, data[:width] * data[:height]}, {:fixed, true}, {:default, :infinity}])
    set_val_in_grid(start_coord, value_at_start_coord, data[:width], distances)
  end

  defp get_neighbor_coords(data, {x, y}) do
    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    |> Enum.map(fn {ox, oy} -> {x + ox, y + oy} end)
    |> Enum.filter(fn {x, y} -> x >= 0 and x < data[:width] and y >= 0 and y < data[:height] end)
  end

  defp pop_coord_with_min_f_score(list, data, f_score) do
    index =
      list
      |> Enum.with_index()
      |> Enum.min_by(fn {coord, _} -> get_val_from_grid(coord, data[:width], f_score) end)
      |> elem(1)

    List.pop_at(list, index)
  end

  defp a_star_fold(neighbor, {current, data, target, priority_queue, g_score, f_score}) do
    neighbor_risk = get_val_from_grid(neighbor, data[:width], data[:risks])
    tentative_g_score = get_val_from_grid(current, data[:width], g_score) + neighbor_risk
    if tentative_g_score < get_val_from_grid(neighbor, data[:width], g_score) do
      g_score_2 = set_val_in_grid(neighbor, tentative_g_score, data[:width], g_score)
      f_score_2 = set_val_in_grid(neighbor, tentative_g_score + manhattan_distance(neighbor, target), data[:width], f_score)
      if not Enum.member?(priority_queue, neighbor) do
        {current, data, target, [neighbor | priority_queue], g_score_2, f_score_2}
      else
        {current, data, target, priority_queue, g_score_2, f_score_2}
      end
    else
      {current, data, target, priority_queue, g_score, f_score}
    end
  end

  defp do_get_total_risk_of_minimal_path(data, target, priority_queue, g_score, f_score) do
    {current, priority_queue_2} = pop_coord_with_min_f_score(priority_queue, data, f_score)
    case current do
      ^target -> get_val_from_grid(target, data[:width], g_score)
      _ ->
        {_, _, _, priority_queue_3, g_score_2, f_score_2} =
          get_neighbor_coords(data, current)
          |> Enum.reduce({current, data, target, priority_queue_2, g_score, f_score}, &a_star_fold/2)

        do_get_total_risk_of_minimal_path(data, target, priority_queue_3, g_score_2, f_score_2)
    end
  end

  defp get_total_risk_of_minimal_path(data, from, to) do
    priority_queue = [from]
    g_score = create_distance_grid(data, from, 0)
    f_score = create_distance_grid(data, from, manhattan_distance(from, to))
    do_get_total_risk_of_minimal_path(data, to, priority_queue, g_score, f_score)
  end

  defp integer_wrap(n), do: rem(n - 1, 9) + 1

  defp grow_cave(small_cave, factor) do
    {prev_w, prev_h} = {small_cave[:width], small_cave[:height]}
    {new_w, new_h} = {prev_w * factor, prev_h * factor}
    large_cave_area = new_w * new_h

    risks =
      0..large_cave_area - 1
      |> Enum.map(fn i ->
        index_into_small_cave = rem(i, prev_w) + rem(prev_w * div(i, new_w), prev_w * prev_h)
        chunk_increment = rem(div(i, prev_w), factor) + div(i, new_w * prev_h)
        integer_wrap(:array.get(index_into_small_cave, small_cave[:risks]) + chunk_increment)
      end)

    %{
      width: small_cave[:width] * 5,
      height: small_cave[:height] * 5,
      risks: :array.from_list(risks)
    }
  end

  defp calculate_solution(cave_data) do
    {top_left, bottom_right} = {{0, 0}, {cave_data[:width] - 1, cave_data[:height] - 1}}
    get_total_risk_of_minimal_path(cave_data, top_left, bottom_right)
  end

  def part_one do
    parse_file()
    |> calculate_solution
  end

  def part_two do
    parse_file()
    |> grow_cave(5)
    |> calculate_solution
  end
end

Day15.part_one |> IO.puts
Day15.part_two |> IO.puts
