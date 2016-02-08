defmodule Trueskill.FactorGraph do

  @beta 25.0/6
  @draw_portability 0.10

  def team_rating(team, options \\ %{}) do
    skills = Trueskill.Factors.PriorFactor.down([team])
    performances = Trueskill.Factors.LikelihoodFactor.down(skills)
    team_performance_options = Map.take(options, [:team_performance_addaptive])
    Trueskill.Factors.SumFactor.down(performances, team_performance_options)
      |> Enum.map(fn(x) -> Trueskill.Variable.to_rating(x) end)
      |> List.first
  end

  def calculate_ratings(teams) do
    calculate_ratings(teams, %{})
  end
  def calculate_ratings(teams, %{}=options) do
    ranks = Range.new(1, Enum.count teams) |> Enum.to_list
    calculate_ratings(teams, ranks, options)
  end
  def calculate_ratings(teams, ranks, options) do
    if Enum.count(teams) != Enum.count(ranks) do
      raise "The count of ranks is wrong."
    end
    [sorted_teams, sorted_ranks, prev_indexs] = sort_by_rank(teams, ranks)

    beta = options[:beta] || @beta
    draw_portability = options[:draw_portability] || @draw_portability

    skills = Trueskill.Factors.PriorFactor.down(sorted_teams)
    performances = Trueskill.Factors.LikelihoodFactor.down(skills)
    team_performance_options = Map.take(options, [:team_performance_addaptive])
    team_performances = Trueskill.Factors.SumFactor.down(performances, team_performance_options)
    margin = draw_margin(draw_portability, beta, Enum.count(teams))
    new_team_performances = Trueskill.Factors.IteratedFactor.iterate(team_performances, sorted_ranks, margin)
    new_performances = Trueskill.Factors.SumFactor.up(new_team_performances, performances, team_performance_options)
    new_skills = Trueskill.Factors.LikelihoodFactor.up(skills, new_performances)
    new_ratings = Trueskill.Factors.PriorFactor.up(new_skills)
    sort_by_index(new_ratings, prev_indexs)
  end

  defp sort_by_rank(teams, ranks) do
    sorted_sets = Enum.zip(teams, ranks)
      |> Enum.with_index
      |> Enum.sort_by(fn({{_team, rank}, _idx}) -> rank end)
    sorted_teams = Enum.map(sorted_sets, fn({{team, _rank}, _idx}) -> team end)
    sorted_ranks = Enum.map(sorted_sets, fn({{_team, rank}, idx}) -> rank end)
    prev_indexs = Enum.map(sorted_sets, fn({{_team, _rank}, idx}) -> idx end)
    [sorted_teams, sorted_ranks, prev_indexs]
  end

  defp sort_by_index(teams, indexs) do
    Enum.zip(teams, indexs)
      |> Enum.sort_by(fn({_team, index}) -> index end)
      |> Enum.map(fn({team, _index}) -> team end)
  end

  defp draw_margin(draw_portability, beta, player_num \\ 2) do
    Statistics.Distributions.Normal.ppf().((draw_portability+1.0) * 0.5) * :math.sqrt(player_num) * beta
  end

end
