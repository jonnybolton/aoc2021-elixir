defmodule Day04 do
  defp parse_board_row(input) do
    input
    |> String.split
    |> Enum.map(fn a -> {String.to_integer(a), :unmarked} end)
  end

  defp parse_board(input) do
    input
    |> Enum.map(&parse_board_row/1)
  end

  defp parse_boards(input) do
    input
    |> Enum.chunk_every(5, 6)
    |> Enum.map(&parse_board/1)
  end

  defp parse_numbers(input) do
    input
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_file do
    [drawn_numbers_input | [_ | boards_input]] =
      System.argv
      |> File.read!
      |> String.trim
      |> String.split("\n")

    {parse_numbers(drawn_numbers_input), parse_boards(boards_input)}
  end

  defp mark_number(board, n) do
    board
    |> Enum.map(fn row ->
      row
      |> Enum.map(fn cell ->
        case cell do
          {^n, _} -> {n, :marked}
          _ -> cell
        end
      end)
    end)
  end

  defp is_row_complete(index, board) do
    board
    |> Enum.at(index)
    |> Enum.all?(fn {_, state} -> state == :marked end)
  end

  defp is_any_row_complete(board) do
    Enum.any?(0..4, fn i -> is_row_complete(i, board) end)
  end

  defp is_column_complete(index, board) do
    board
    |> Enum.map(fn row -> Enum.at(row, index) end)
    |> Enum.all?(fn {_, state} -> state == :marked end)
  end

  defp is_any_column_complete(board) do
    Enum.any?(0..4, fn i -> is_column_complete(i, board) end)
  end

  defp is_complete(board) do
    is_any_row_complete(board) or is_any_column_complete(board)
  end

  defp get_winner_or_loser(boards, :winner) do
    {boards, Enum.find(boards, nil, &is_complete/1)}
  end

  defp get_winner_or_loser(boards, :loser) do
    case boards do
      [board | []] -> if is_complete(board) do {[], board} else {boards, nil} end
      _ -> {Enum.filter(boards, fn board -> not is_complete(board) end), nil}
    end
  end

  defp find_final_board_and_last_number(boards, [next_number | future_numbers], winner_or_loser) do
    {updated_boards, result} =
      boards
      |> Enum.map(fn board -> mark_number(board, next_number) end)
      |> get_winner_or_loser(winner_or_loser)

    case result do
      nil -> find_final_board_and_last_number(updated_boards, future_numbers, winner_or_loser)
      board -> {board, next_number}
    end
  end

  defp sum_of_unmarked_numbers(board) do
    board
    |> List.flatten
    |> Enum.filter(fn {_, state} -> state == :unmarked end)
    |> Enum.reduce(0, fn {n, _}, acc -> n + acc end)
  end

  defp find_final_score(boards, drawn_numbers, winner_or_loser) do
    {board, last_number} = find_final_board_and_last_number(boards, drawn_numbers, winner_or_loser)
    sum_of_unmarked_numbers(board) * last_number
  end

  def part_one do
    {drawn_numbers, boards} = parse_file()
    find_final_score(boards, drawn_numbers, :winner)
  end

  def part_two do
    {drawn_numbers, boards} = parse_file()
    find_final_score(boards, drawn_numbers, :loser)
  end
end

Day04.part_one |> IO.puts
Day04.part_two |> IO.puts
