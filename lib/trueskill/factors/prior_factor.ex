defmodule Trueskill.Factors.PriorFactor do
  alias Trueskill.Gaussian.Distribution, as: Gaussian

  def down(teams) do
    Enum.map(teams, fn(team) ->
      Enum.map(team, fn(player) ->
        Gaussian.new(player.mean, :math.sqrt(:math.pow(player.deviation, 2) + :math.pow(25.0/300, 2)))
      end)
    end)
  end

  def up(teams) do
    Enum.map(teams, fn(team) ->
      Enum.map(team, fn(player) ->
        Trueskill.Rating.new(player.mu, player.sigma)
      end)
    end)
  end

end
