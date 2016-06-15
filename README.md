Trueskill
=========

Usage
----

Example:


```
alias Trueskill.Rating
alias Trueskill.FactorGraph

team1 = [Rating.new(1600, 1600/3)]
team2 = [Rating.new(1500, 1500/3), Rating.new(1400, 1400/3)]
team3 = [Rating.new(1300, 1300/3), Rating.new(1200, 1200/3)]

new_ratings =
  FactorGraph.calculate_ratings([team1, team2, team3], [1, 2, 3], %{team_performance_adaptive: false})
new_ratings =
  FactorGraph.calculate_ratings([team1, team2, team3], %{team_performance_adaptive: false})

new_ratings =
  FactorGraph.calculate_ratings([team1, team2, [1, 2, 1], %{team_performance_adaptive: false})

team_rating = FactorGraph.team_rating(team1)
```
