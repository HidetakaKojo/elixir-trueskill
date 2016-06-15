defmodule Trueskill.FactorGraphSpec do
  use ESpec

  alias Trueskill.Rating
  alias Trueskill.FactorGraph

  describe "calculate_rating" do
    let :team1, do: [Rating.new(2000.0, 2000.0/3), Rating.new(1600.0, 1600.0/3), Rating.new(1200.0, 1200.0/3), Rating.new(1000.0, 1000.0/3)]
    let :team2, do: [Rating.new(1800.0, 1800.0/3), Rating.new(1800.0, 1800.0/3), Rating.new(1800.0, 1800.0/3)]

    context "when team1 won" do
      it do
        [[u1,u2,u3,u4],[u5,u6,u7]] = FactorGraph.calculate_ratings([team1, team2], [1, 2], %{team_performance_adaptive: false})
        IO.inspect u1
        IO.inspect u5
        expect(u1.mean).to be :>, 2000.0
        expect(u2.mean).to be :>, 1600.0
        expect(u3.mean).to be :>, 1200.0
        expect(u4.mean).to be :>, 1000.0
        expect(u5.mean).to be :<, 1800.0
        expect(u6.mean).to be :<, 1800.0
        expect(u7.mean).to be :<, 1800.0
      end
    end
    context "with draw" do
      it do
        [[u1,u2,u3,u4],[u5,u6,u7]] = FactorGraph.calculate_ratings([team1, team2], [1, 1], %{team_performance_adaptive: false})
        expect(u1.mean).to be :>, 2000.0
        expect(u2.mean).to be :>, 1600.0
        expect(u3.mean).to be :>, 1200.0
        expect(u4.mean).to be :>, 1000.0
        expect(u5.mean).to be :<, 1800.0
        expect(u6.mean).to be :<, 1800.0
        expect(u7.mean).to be :<, 1800.0
      end
    end
    context "when team2 won" do
      it do
        [[u5,u6,u7],[u1,u2,u3,u4]] = FactorGraph.calculate_ratings([team2, team1], [1, 2], %{team_performance_adaptive: false})
        expect(u1.mean).to be :<, 2000.0
        expect(u2.mean).to be :<, 1600.0
        expect(u3.mean).to be :<, 1200.0
        expect(u4.mean).to be :<, 1000.0
        expect(u5.mean).to be :>, 1800.0
        expect(u6.mean).to be :>, 1800.0
        expect(u7.mean).to be :>, 1800.0
      end
    end
  end
end
