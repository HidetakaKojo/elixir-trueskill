defmodule Trueskill.Factors.TruncateFactor do
  alias Trueskill.Gaussian.Distribution, as: Gaussian
  alias Statistics.Distributions.Normal, as: Statistics

  def update(diffs, ranks, epsilon) do
    compared_diffs = Enum.with_index(diffs) |> Enum.map(fn({diff, idx}) ->
      old_message = diff.messages.truncate
      tmp_message = Gaussian.divide(diff.value, old_message)
      pi_s = :math.sqrt(tmp_message.pi)
      tau_s = case :erlang.float(pi_s) do
        0.0 -> 0.0
        x when is_number(x) -> tmp_message.tau / pi_s
      end
      eps_s = epsilon * pi_s
      new_value = if (Enum.fetch!(ranks, idx) == Enum.fetch!(ranks, idx+1)) do
        truncate_same(eps_s, tau_s, tmp_message)
      else
        truncate_greater_than(eps_s, tau_s, tmp_message)
      end
      new_message = Gaussian.multiply(new_value, old_message)
        |> Gaussian.divide(diff.value)
      %Trueskill.Variable{value: new_value, messages: Map.merge(diff.messages, %{truncate: new_message})}
    end)
    delta = Enum.with_index(compared_diffs) |> Enum.map(fn({diff, idx}) ->
      Gaussian.subtract(diff.value, Enum.fetch!(diffs, idx).value)
    end) |> Enum.max
    [compared_diffs, delta]
  end

  def truncate_same(eps_s, tau_s, message) do
    denom = 1.0 - Trueskill.Gaussian.TruncatedCorrection.w_within_margin(tau_s, eps_s)
    new_pi = message.pi / denom
    new_tau = (message.tau + :math.sqrt(message.pi) * Trueskill.Gaussian.TruncatedCorrection.v_within_margin(tau_s, eps_s))/denom
    Gaussian.new_with_precision(new_tau/new_pi, new_pi)
  end

  def truncate_greater_than(eps_s, tau_s, message) do
    denom = 1.0 - Trueskill.Gaussian.TruncatedCorrection.w_exceeds_margin(tau_s, eps_s)
    new_pi = message.pi / denom
    new_tau = (message.tau + :math.sqrt(message.pi) * Trueskill.Gaussian.TruncatedCorrection.v_exceeds_margin(tau_s, eps_s))/denom
    Gaussian.new_with_precision(new_tau/new_pi, new_pi)
  end
end
