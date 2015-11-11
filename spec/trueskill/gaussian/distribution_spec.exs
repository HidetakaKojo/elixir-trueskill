defmodule Trueskill.Gaussian.DistributionSpec do
  use ESpec
  alias Trueskill.Gaussian.Distribution, as: Gaussian

  describe "new" do
    it do
      expect(Gaussian.new(10.1, 0.4).mu).to eq 10.1
    end
    it do
      expect(Gaussian.new(10.1, 0.4).sigma).to eq 0.4
    end
    it do
      expect(Gaussian.new(:infinity, 0.4).mu).to eq 0.0
    end
    it do
      expect(Gaussian.new(10.1, :infinity).sigma).to eq 0.0
    end
    it do
      expect(Gaussian.new.mu).to eq 0.0
    end
  end

  describe "new_with_precision" do
    it do
      expect(Gaussian.new_with_precision(25.0, 0.0144).mu).to eq 25.0
    end
    it do
      expect(Gaussian.new_with_precision(25.0, 0.0144).sigma).to eq 8.333333333333334
    end
  end

  describe "multiply" do
    it do
      expect(Gaussian.multiply(Gaussian.new(0, 1), Gaussian.new(2, 3)).mu).to be_close_to(0.2, 0.0001)
      expect(Gaussian.multiply(Gaussian.new(0, 1), Gaussian.new(2, 3)).sigma).to be_close_to((3.0 / :math.sqrt(10)), 0.001)
    end
  end

  describe "subtract" do
    let :dist do
      Gaussian.new(25.0, 8.333333)
    end
    it do
      expect(Gaussian.subtract(dist, dist)).to eq 0.0
      expect(Gaussian.subtract(dist, Gaussian.new)).to eq dist.tau
      expect(Gaussian.subtract(Gaussian.new(22, 0.4), Gaussian.new(12, 1.3))).to be_close_to(130.399408, 0.001)
    end
  end

  describe "value_at" do
    it do
      expect(Gaussian.value_at(Gaussian.new(4, 5), 2)).to be_close_to(0.073654, 0.001)
    end
  end
end
