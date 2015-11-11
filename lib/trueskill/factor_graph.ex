defmodule Trueskill.FactorGraph do

  @beta 25.0/6
  @draw_portability 0.10
  @gamma 25.0/300

  defp sort_by_rank(teams, ranks) do
    sorted_sets = List.zip([teams, ranks])
      |> Enum.sort_by(fn(x) -> elem(x, 1) end)
    sorted_teams = Enum.map(sorted_sets, fn(x) -> elem(x, 0) end)
    sorted_ranks = Enum.map(sorted_sets, fn(x) -> elem(x, 1) end)
    [sorted_teams, sorted_ranks]
  end

  def calculate(teams) do
    calculate(teams, %{})
  end
  def calculate(teams, %{}=options) do
    ranks = Range.new(1, Enum.count teams) |> Enum.to_list
    calculate(teams, ranks, options)
  end
  def calculate(teams, ranks, options) do
    if Enum.count(teams) != Enum.count(ranks) do
      raise "The count of ranks is wrong."
    end
    [sorted_teams, sorted_ranks] = sort_by_rank(teams, ranks)

    beta = options[:beta] || @beta
    draw_portability = options[:draw_portability] || @draw_portability
    gamma = options[:gamma] || @gamma

    skills = Trueskill.Factors.PriorFactor.down(sorted_teams)
    performances = Trueskill.Factors.LikelihoodFactor.down(skills)
    team_performance_options = Map.take(options, [:team_performance_addaptive])
    team_performances = Trueskill.Factors.SumFactor.down(performances, team_performance_options)
    margin = draw_margin(draw_portability, beta, Enum.count(teams))
    new_team_performances = Trueskill.Factors.IteratedFactor.iterate(team_performances, sorted_ranks, margin)
    new_performances = Trueskill.Factors.SumFactor.up(new_team_performances, performances, team_performance_options)
    new_skills = Trueskill.Factors.LikelihoodFactor.up(skills, new_performances)
    new_ratings = Trueskill.Factors.PriorFactor.up(new_skills)
  end

  defp draw_margin(draw_portability, beta, player_num \\ 2) do
    Statistics.Distributions.Normal.ppf((draw_portability+1.0) * 0.5) * :math.sqrt(player_num) * beta
  end

end
