defmodule Trueskill.Gaussian.TruncatedCorrectionSpec do
  use ESpec
  alias Trueskill.Gaussian.TruncatedCorrection, as: Correction

  describe "w_exceeds_margin" do
    it do
      expect(Correction.w_exceeds_margin(0.0, 0.740466)).to be_close_to(0.76774506, 0.0001)
      expect(Correction.w_exceeds_margin(0.2, 0.3)).to be_close_to(0.657847, 0.0001)
      expect(Correction.w_exceeds_margin(0.1, 0.03)).to be_close_to(0.621078, 0.0001)
      expect(Correction.w_exceeds_margin(15.0, 0.0050)).to be_close_to(3.0114020647018144e-16, 1.0e-17)
    end
  end

  describe "v_within_margin" do
    it do
      expect(Correction.v_within_margin(0.2, 0.3)).to be_close_to(-0.194073, 0.0001)
      expect(Correction.v_within_margin(0.1, 0.03)).to be_close_to(-0.09997, 0.0001)
    end
  end

  describe "v_exceeds_margin" do
    it do
      expect(Correction.v_exceeds_margin(0.0, 0.740466)).to be_close_to(1.32145197, 0.0001)
      expect(Correction.v_exceeds_margin(0.2, 0.3)).to be_close_to(0.8626174, 0.0001)
      expect(Correction.v_exceeds_margin(0.1, 0.03)).to be_close_to(0.753861, 0.0001)
    end
  end

  describe "w_within_margin" do
    it do
      expect(Correction.w_within_margin(0.2, 0.3)).to be_close_to(0.970397, 0.0001)
      expect(Correction.w_within_margin(0.1, 0.03)).to be_close_to(0.9997, 0.0001)
    end
  end
end
