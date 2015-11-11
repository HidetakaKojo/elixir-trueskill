defmodule Trueskill.Gaussian.Distribution do
  alias Trueskill.Gaussian.Distribution
  defstruct mu: 0.0, sigma: 0.0, pi: 0.0, tau: 0.0

  def new(:infinity, sigma) do
    new(0.0, sigma)
  end
  def new(mu, :infinity) do
    new(0.0, 0.0)
  end
  def new(mu, sigma) do
    pi = case :erlang.float(sigma) do
      0.0 -> 0.0
      x when is_number(x) -> 1 / :math.pow(x, 2)
    end
    tau = pi * mu
    %Distribution{mu: mu, sigma: sigma, pi: pi, tau: tau}
  end
  def new_with_precision(mu, pi) do
    case :erlang.float(pi) do
      0.0 -> 
        Distribution.new(mu, :infinity)
      x when is_number(x) ->
        Distribution.new(mu, :math.sqrt(1 / pi))
    end
  end
  def new do
    Distribution.new_with_precision(0.0, 0.0)
  end

  def multiply(%Distribution{}=arg1, %Distribution{}=arg2) do
    pi = arg1.pi + arg2.pi
    mu = case :erlang.float(pi) do
      0.0 -> :infinity
      _ -> (arg1.tau + arg2.tau) / pi
    end
    Distribution.new_with_precision(mu, pi)
  end

  def divide(%Distribution{}=arg1, %Distribution{}=arg2) do
    pi = arg1.pi - arg2.pi
    mu = case :erlang.float(pi) do
      0.0 -> :infinity
      _ -> (arg1.tau - arg2.tau) / pi
    end
    Distribution.new_with_precision(mu, pi)
  end

  def subtract(%Distribution{}=arg1, %Distribution{}=arg2) do
    max(abs(arg1.tau - arg2.tau), :math.sqrt(abs(arg1.pi - arg2.pi)))
  end

  def value_at(%Distribution{}=gaussian, x) do
    exp = - :math.pow((x - gaussian.mu), 2) / (2.0 * :math.pow(gaussian.sigma,2))
    (1.0 / gaussian.sigma) * (1 / :math.sqrt(2 * :math.pi())) * :math.exp(exp)
  end
end
