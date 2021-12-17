defmodule Day17 do
  defp parse_file do
    [x0, x1, y0, y1] =
      System.argv
      |> File.read!
      |> String.trim
      |> String.split(["=", "..", ","])
      |> List.delete_at(3)
      |> List.delete_at(0)
      |> Enum.map(&String.to_integer/1)

    [x0: x0, x1: x1, y0: y0, y1: y1]
  end

  defp get_highest_y_position_from_initial_vertical_velocity(vy) do
    if vy <= 0, do: 0, else: div(vy * (vy + 1), 2)
  end

  defp get_range_of_possible_initial_horizontal_velocities(input) do
    min = if input[:x0] < 0, do: -input[:x0], else: floor(:math.sqrt(2 * input[:x0]) - 1)
    max = if input[:x1] >= 0, do: input[:x1], else: -floor(:math.sqrt(2 * -input[:x1]) - 1)
    min..max
  end

  defp get_range_of_possible_initial_vertical_velocities(input) do
    x = max(abs(input[:y0]), abs(input[:y1]))
    x..-x
  end

  defp is_in_target(input, {x, y}) do
    x >= input[:x0] and x <= input[:x1] and y >= input[:y0] and y <= input[:y1]
  end

  defp increment_velocity({vx, vy}) when vx > 0, do: {vx - 1, vy - 1}
  defp increment_velocity({vx, vy}) when vx < 0, do: {vx + 1, vy - 1}
  defp increment_velocity({_, vy}), do: {0, vy - 1}

  defp can_end_in_target(input, {vx, vy}, {x0, y0} \\ {0, 0}) do
    if is_in_target(input, {x0, y0}) do
      true
    else if y0 < input[:y0] do
      false
    else
      can_end_in_target(input, increment_velocity({vx, vy}), {x0 + vx, y0 + vy})
    end
    end
  end

  defp can_end_in_target_with_initial_y(input, initial_y, x_range) do
    x_range
    |> Enum.any?(fn vx -> can_end_in_target(input, {vx, initial_y}) end)
  end

  defp get_highest_possible_y_position(input) do
    x_range = get_range_of_possible_initial_horizontal_velocities(input)
    y_range = get_range_of_possible_initial_vertical_velocities(input)
    best_y_velocity = Enum.find(y_range, &can_end_in_target_with_initial_y(input, &1, x_range))
    get_highest_y_position_from_initial_vertical_velocity(best_y_velocity)
  end

  defp get_total_number_of_valid_inital_velocities(input) do
    x_range = get_range_of_possible_initial_horizontal_velocities(input)
    y_range = get_range_of_possible_initial_vertical_velocities(input)
    y_range
    |> Enum.map(fn vy ->
      x_range
      |> Enum.filter(fn vx -> can_end_in_target(input, {vx, vy}) end)
      |> Enum.count
    end)
    |> Enum.sum
  end

  def part_one, do: parse_file() |> get_highest_possible_y_position
  def part_two, do: parse_file() |> get_total_number_of_valid_inital_velocities
end

Day17.part_one |> IO.puts
Day17.part_two |> IO.puts
