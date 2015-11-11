defmodule Trueskill.Gaussian.TruncatedCorrection do
  alias Trueskill.Gaussian.Distribution, as: Gaussian
  alias Statistics.Distributions.Normal, as: Statistics

  def w_exceeds_margin(diff, epsilon) do
    if Statistics.cdf(diff - epsilon) < 2.2e-162 do
      if((diff < 0.0),  do: 1.0, else: 0.0)
    else
      v = v_exceeds_margin(diff, epsilon)
      v * (v + diff - epsilon)
    end
  end

  def w_within_margin(diff, epsilon) do
    abs_diff = abs(diff)
    denom = Statistics.cdf(epsilon - abs_diff) - Statistics.cdf(-epsilon - abs_diff)
    if denom < 2.2e-162 do
      1.0
    else
      vt = v_within_margin(abs_diff, epsilon)
      :math.pow(vt, 2) + (
        (epsilon - abs_diff) *
        Gaussian.value_at(Gaussian.new(0, 1.0), (epsilon - abs_diff)) -
        (-epsilon - abs_diff) *
        Gaussian.value_at(Gaussian.new(0, 1.0), (-epsilon - abs_diff))
      ) / denom
    end
  end

  def v_exceeds_margin(diff, epsilon) do
    denom = Statistics.cdf(diff - epsilon)
    if (denom < 2.2e-162) do
      -diff + epsilon
    else
      Gaussian.value_at(Gaussian.new(0, 1.0), (diff - epsilon)) / denom
    end
  end

  def v_within_margin(diff, epsilon) do
    abs_diff = abs(diff)
    denom = Statistics.cdf(epsilon - abs_diff) - Statistics.cdf(-epsilon - abs_diff)
    if denom < 2.2e-162 do
      if diff < 0 do
        - diff - epsilon
      else
        - diff + epsilon
      end
    else
      num = Gaussian.value_at(Gaussian.new(0, 1.0), (-epsilon - abs_diff)) -
        Gaussian.value_at(Gaussian.new(0, 1.0), (epsilon - abs_diff))
      if diff < 0 do
        - num / denom
      else
        num / denom
      end
    end
  end

end
