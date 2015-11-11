defmodule Trueskill.Factors.IteratedFactor do

  @iterate_count 5

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
    team_performance_diffs = Trueskill.Factors.DiffFactor.diff_teams(team_performances, false)
    truncated_diffs = Trueskill.Factors.TruncateFactor.update(team_performance_diffs, ranks, draw_margin)
    new_team_performances = Trueskill.Factors.DiffFactor.update_team(truncated_diffs, team_performances, false)
    Trueskill.Variable.merge_messages(:sum, new_team_performances, team_performances)
  end

  defp compare_multi_teams(team_performances, ranks, draw_margin, options) do
    compare_multi_teams(team_performances, ranks, draw_margin, options, @iterate_count)
  end
  defp compare_multi_teams(team_performances, _ranks, _draw_margin, _options, 0) do
    team_performances
  end
  defp compare_multi_teams(team_performances, ranks, draw_margin, options, num) do
    team_performance_diffs = Trueskill.Factors.DiffFactor.diff_teams(team_performances, false)
    truncated_diffs = Trueskill.Factors.TruncateFactor.update(team_performance_diffs, ranks, draw_margin)
    new_team_performances = Trueskill.Factors.DiffFactor.update_team(truncated_diffs, team_performances, false)

    reversed_team_performance_diffs = Trueskill.Factors.DiffFactor.diff_teams(Enum.reverse(new_team_performances), true)
    reversed_truncated_diffs = Trueskill.Factors.TruncateFactor.update(reversed_team_performance_diffs, Enum.reverse(ranks), draw_margin)
    reversed_new_team_performances = Trueskill.Factors.DiffFactor.update_team(reversed_truncated_diffs, Enum.reverse(team_performances), true)

    compare_multi_teams(Enum.reverse(reversed_new_team_performances), ranks, draw_margin, options, num - 1)
  end
end
