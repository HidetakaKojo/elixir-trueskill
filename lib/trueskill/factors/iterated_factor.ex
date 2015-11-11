defmodule Trueskill.Factors.IteratedFactor do

  @max_delta 0.0001

  def iterate(team_performances, ranks, draw_margin) do
    iterate(team_performances, ranks, draw_margin, %{})
  end
  def iterate(team_performances, ranks, draw_margin, %{}=options) do
    if Enum.count(team_performances) == 2 do
      compare_two_teams(team_performances, ranks, draw_margin, options)
    else
      compare_multi_teams(team_performances, ranks, draw_margin, options)
    end
  end

  defp compare_two_teams(team_performances, ranks, draw_margin, options) do
      [team_performance_diffs, _diff_delta] = Trueskill.Factors.DiffFactor.diff_teams(team_performances)
      [truncated_diffs, _truncate_delta] = Trueskill.Factors.TruncateFactor.update(team_performance_diffs, ranks, draw_margin)
      [new_team_performances, _update_delta] = Trueskill.Factors.DiffFactor.update_team(truncated_diffs, team_performances)
      Trueskill.Variable.merge_messages(:sum, new_team_performances, team_performances)
  end

  defp compare_multi_teams(team_performances, ranks, draw_margin, options) do
    compare_multi_teams(team_performances, ranks, draw_margin, options, 5)
  end
  defp compare_multi_teams(team_performances, _ranks, _draw_margin, _options, 0) do
    team_performances
  end
  defp compare_multi_teams(team_performances, ranks, draw_margin, options, num) do
    max_delta = options[:max_delta] || @max_delta
    [team_performance_diffs, diff_delta] = Trueskill.Factors.DiffFactor.diff_teams(team_performances)
    [truncated_diffs, truncate_delta] = Trueskill.Factors.TruncateFactor.update(team_performance_diffs, ranks, draw_margin)
    [new_team_performances, update_delta] = Trueskill.Factors.DiffFactor.update_team(truncated_diffs, team_performances)
    compare_multi_teams(new_team_performances, ranks, draw_margin, options, num - 1)
  end
end
