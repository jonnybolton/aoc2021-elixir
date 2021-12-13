defmodule Day10 do
  defp parse_file do
    System.argv
    |> File.read!
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&String.to_charlist/1)
  end

  defp parse_chunk(input, open_braces \\ []) do
    case {input, open_braces} do
      {[], _} -> {0, open_braces}
      {[?( | tail], _} -> parse_chunk(tail, [?( | open_braces])
      {[?[ | tail], _} -> parse_chunk(tail, [?[ | open_braces])
      {[?{ | tail], _} -> parse_chunk(tail, [?{ | open_braces])
      {[?< | tail], _} -> parse_chunk(tail, [?< | open_braces])
      {[?) | tail], [?( | braces_tail]} -> parse_chunk(tail, braces_tail)
      {[?] | tail], [?[ | braces_tail]} -> parse_chunk(tail, braces_tail)
      {[?} | tail], [?{ | braces_tail]} -> parse_chunk(tail, braces_tail)
      {[?> | tail], [?< | braces_tail]} -> parse_chunk(tail, braces_tail)
      {[?) | _], _} -> {3, open_braces}
      {[?] | _], _} -> {57, open_braces}
      {[?} | _], _} -> {1197, open_braces}
      {[?> | _], _} -> {25137, open_braces}
    end
  end

  defp get_completion_score_from_open_braces(braces, acc \\ 0) do
    case braces do
      [] -> acc
      [?( | tail] -> get_completion_score_from_open_braces(tail, (acc * 5) + 1)
      [?[ | tail] -> get_completion_score_from_open_braces(tail, (acc * 5) + 2)
      [?{ | tail] -> get_completion_score_from_open_braces(tail, (acc * 5) + 3)
      [?< | tail] -> get_completion_score_from_open_braces(tail, (acc * 5) + 4)
    end
  end

  defp get_completion_scores(input) do
    input
    |> Enum.map(&parse_chunk/1)
    |> Enum.filter(fn {error_score, _} -> error_score == 0 end)
    |> Enum.map(fn {_, open_braces} -> get_completion_score_from_open_braces(open_braces) end)
  end

  def part_one do
    parse_file()
    |> Enum.map(fn line -> line |> parse_chunk |> elem(0) end)
    |> Enum.sum
  end

  def part_two do
    scores =
      parse_file()
      |> get_completion_scores
      |> Enum.sort

    Enum.at(scores, div(Enum.count(scores) - 1, 2))
  end
end

Day10.part_one |> IO.puts
Day10.part_two |> IO.puts
