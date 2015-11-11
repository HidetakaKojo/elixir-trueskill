defmodule Trueskill.Factors.PriorFactorSpec do
  use ESpec
  alias Trueskill.Factors.PriorFactor
  alias Trueskill.Gaussian.Distribution, as: Gaussian
  alias Trueskill.Rating

  describe "down" do
    let :player1, do: Rating.new(1500, 25)
    let :player2, do: Rating.new(1600, 30)
    let :player3, do: Rating.new(1400, 50)
    let :team1, do: [player1]
    let :team2, do: [player2,player3]

    it do
      [[skill1],[skill2, skill3]] = PriorFactor.down([team1, team2])
      expect(skill1.mu).to eq 1500
      expect(skill1.sigma).to be_close_to(25, 0.001)
      expect(skill2.mu).to eq 1600
      expect(skill2.sigma).to be_close_to(30, 0.001)
      expect(skill3.mu).to eq 1400
      expect(skill3.sigma).to be_close_to(50, 0.001)
    end
  end
end
