defmodule Trueskill.Rating do
  alias Trueskill.Gaussian.Distribution, as: Gaussian
  defstruct mean: 0.0, deviation: 100.0

  def new(mean, deviation) do
    %Trueskill.Rating{mean: mean, deviation: deviation}
  end
end
