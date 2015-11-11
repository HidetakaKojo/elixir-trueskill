defmodule Trueskill.Factors.DiffFactor do
  import Trueskill.Factors.SumFactorBase
  alias Trueskill.Gaussian.Distribution, as: Gaussian

  def diff_teams(performances) do
    diffs = Range.new(0, (Enum.count(performances) - 2))
      |> Enum.to_list
      |> Enum.map(fn(_) ->
        %Trueskill.Variable{value: Gaussian.new, messages: %{diff: Gaussian.new, truncate: Gaussian.new}}
      end)
    diff_teams(performances, diffs)
  end
  def diff_teams(performances, diffs) do
    coefficients = [1, -1]
    length = Enum.count performances
    new_diffs = Range.new(0, length-2)
      |> Enum.to_list
      |> Enum.map(fn(index) ->
           input_values = Enum.slice(performances, index, 2) |> Enum.map(fn(x) -> x.value end)
           input_messages = Enum.slice(performances, index, 2) |> Enum.map(fn(x) -> x.messages.diff end)
           diff = Enum.fetch!(diffs, index)
           [new_value, new_message] = sum(diff.value, diff.messages.diff, input_values, input_messages, coefficients)
           %Trueskill.Variable{value: new_value, messages: Map.merge(diff.messages, %{diff: new_message})}
         end)
    delta = Enum.with_index(new_diffs) |> Enum.map(fn({diff, idx}) ->
      Gaussian.subtract(diff.value, Enum.fetch!(diffs, idx).value)
    end) |> Enum.max
    [new_diffs, delta]
  end

  def update_team(diffs, team_performances) do
    new_team_performances = update_team_recursive(diffs, team_performances)
    delta = Enum.with_index(new_team_performances) |> Enum.map(fn({perf, idx}) ->
      Gaussian.subtract(perf.value, Enum.fetch!(team_performances, idx).value)
    end) |> Enum.max
    [new_team_performances, delta]
  end
  def update_team_recursive([], [rest_team]) do
    [rest_team]
  end
  def update_team_recursive([first_diff|diffs], [first_team|teams]) do
    [second_team|rest_teams] = teams

    first_input_values = [first_diff, second_team] |> Enum.map(fn(x) -> x.value end)
    first_input_messages = [first_diff, second_team] |> Enum.map(fn(x) -> x.messages.diff end)
    [new_first_team_value, new_first_team_message] =
      sum(first_team.value, first_team.messages.diff, first_input_values, first_input_messages, [1, 1])
    new_first_team =%Trueskill.Variable{
      value: new_first_team_value,
      messages: Map.merge(first_team.messages, %{diff: new_first_team_message})}

    second_input_values = [first_team, first_diff] |> Enum.map(fn(x) -> x.value end)
    second_input_messages = [first_team, first_diff] |> Enum.map(fn(x) -> x.messages.diff end)
    [new_second_team_value, new_second_team_message] =
      sum(second_team.value, second_team.messages.diff, second_input_values, second_input_messages, [1, -1])
    new_second_team =%Trueskill.Variable{
      value: new_second_team_value,
      messages: Map.merge(second_team.messages, %{diff: new_second_team_message})}

    [new_first_team] ++ update_team_recursive(diffs, [new_second_team|rest_teams])
  end
end
