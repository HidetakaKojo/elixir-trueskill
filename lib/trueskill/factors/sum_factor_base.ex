defmodule Trueskill.Factors.SumFactorBase do
  alias Trueskill.Gaussian.Distribution, as: Gaussian

  def adjust_coefficients(coefficients, addaptive) do
    input_size = Enum.count(coefficients)
    Enum.map(coefficients, fn(x) ->
      case addaptive do
        false -> x / input_size
        true  -> x
      end
    end)
  end

  def sum(sum_value, sum_message, input_values, input_messages, coefficients) do
    new_pi = 1 / (Enum.with_index(coefficients) |> Enum.reduce(0.0, fn({x, idx}, acc) ->
      value = Enum.fetch!(input_values, idx)
      message = Enum.fetch!(input_messages, idx)
      acc + case (value.pi - message.pi) do
        0.0 -> 0.0
        _ -> (:math.pow(x, 2) / (value.pi - message.pi))
      end
    end))
    new_tau = new_pi * (Enum.with_index(coefficients) |> Enum.reduce(0.0, fn({x, idx}, acc) ->
      value = Enum.fetch!(input_values, idx)
      message = Enum.fetch!(input_messages, idx)
      acc + case (value.pi - message.pi) do
        0.0 -> 0.0
        _ -> (x * (value.tau - message.tau) / (value.pi - message.pi))
      end
    end))
    new_mean = new_tau / new_pi
    new_message = Gaussian.new_with_precision(new_mean, new_pi)
    new_value = Gaussian.divide(sum_value, sum_message)
      |> Gaussian.multiply(new_message)
    [new_value, new_message]
  end
end
