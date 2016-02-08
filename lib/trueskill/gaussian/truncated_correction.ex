defmodule Trueskill.Gaussian.TruncatedCorrection do
  alias Trueskill.Gaussian.Distribution, as: Gaussian
  alias Statistics.Distributions.Normal, as: Statistics

  @minimum_number 2.008270800067899e-17

  def v_exceeds_margin(diff, epsilon) do
    denom = Statistics.cdf().(diff - epsilon)
    if denom == 0.0 do
      -diff + epsilon
    else
      Gaussian.value_at(Gaussian.new(0, 1.0), (diff - epsilon)) / denom
    end
  end

  def w_exceeds_margin(diff, epsilon) do
    v = Enum.max([v_exceeds_margin(diff, epsilon), @minimum_number])
    v * (v + diff - epsilon)
  end

  def v_within_margin(diff, epsilon) do
    abs_diff = abs(diff)
    denom = Statistics.cdf().(epsilon - abs_diff) - Statistics.cdf().(-epsilon - abs_diff)
    numer = Statistics.pdf().(-epsilon - abs_diff) - Statistics.pdf().(epsilon - abs_diff)
    v = if denom == 0.0 do
      epsilon - abs_diff
    else
      numer / denom
    end
    if diff < 0 do
      - v
    else
      v
    end
  end

  def w_within_margin(diff, epsilon) do
    abs_diff = abs(diff)
    denom = Statistics.cdf().(epsilon - abs_diff) - Statistics.cdf().(-epsilon - abs_diff)
    vt = v_within_margin(abs_diff, epsilon)
    :math.pow(vt, 2) + (
      (epsilon - abs_diff) *
      Statistics.pdf().(epsilon - abs_diff) -
      (-epsilon - abs_diff) *
      Statistics.pdf().(-epsilon - abs_diff)
    ) / denom
  end

end
