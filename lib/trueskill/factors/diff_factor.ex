defmodule Trueskill.Factors.DiffFactor do
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
           performance1 = Enum.fetch!(performances, index)
           performance2 = Enum.fetch!(performances, index+1)
           diff = Enum.fetch!(diffs, index)
           [new_value, new_message] = diff_team([performance1, performance2], diff, coefficients)
           %Trueskill.Variable{value: new_value, messages: Map.merge(diff.messages, %{diff: new_message})}
         end)
    delta = Enum.with_index(new_diffs) |> Enum.map(fn({diff, idx}) ->
      Gaussian.subtract(diff.value, Enum.fetch!(diffs, idx).value)
    end) |> Enum.max
    [new_diffs, delta]
  end

  def diff_team(performances, diff, coefficients) do
    new_pi = 1 / (Enum.with_index(performances) |> Enum.reduce(0.0, fn({x, idx}, acc) ->
      message = x.messages.diff
      acc + (:math.pow(Enum.fetch!(coefficients, idx), 2) / (x.value.pi - message.pi))
    end))
    new_tau = new_pi * (Enum.with_index(performances) |> Enum.reduce(0.0, fn({x, idx}, acc) ->
      message = x.messages.diff
      acc + (Enum.fetch!(coefficients, idx) * (x.value.tau - message.tau) / (x.value.pi - message.pi))
    end))
    new_mean = new_tau / new_pi
    new_message = Gaussian.new_with_precision(new_mean, new_pi)
    new_value = Gaussian.divide(diff.value, diff.messages.diff)
      |> Gaussian.multiply(new_message)
    [new_value, new_message]
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

    first_team_coefficients = [1, 1]
    [new_first_team_value, new_first_team_message] =
      diff_team([first_diff, second_team], first_team, first_team_coefficients)
    new_first_team =%Trueskill.Variable{
      value: new_first_team_value,
      messages: Map.merge(first_team.messages, %{diff: new_first_team_message})}

    second_team_coefficients = [1, -1]
    [new_second_team_value, new_second_team_message] =
      diff_team([first_team, first_diff], second_team, second_team_coefficients)
    new_second_team =%Trueskill.Variable{
      value: new_second_team_value,
      messages: Map.merge(second_team.messages, %{diff: new_second_team_message})}

    [new_first_team] ++ update_team_recursive(diffs, [new_second_team|rest_teams])
  end
end
