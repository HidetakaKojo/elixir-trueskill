defmodule Trueskill.Factors.SumFactor do
  import Trueskill.Factors.SumFactorBase
  alias Trueskill.Gaussian.Distribution, as: Gaussian

  def down(performances, options) do
    addaptive = options[:team_performance_addaptive]
    Enum.map(performances, fn(performance) ->
      input_values = Enum.map(performance, fn(x) ->
        x.value
      end)
      input_messages = Enum.map(performance, fn(x) ->
        case Map.fetch!(x.messages, :sum) do
          nil -> Gaussian.new
          x -> x
        end
      end)
      coefficients = Enum.map(performance, fn(_) -> 1 end)
        |> adjust_coefficients(addaptive)
      [new_value, new_message] = sum(Gaussian.new, Gaussian.new, input_values, input_messages, coefficients)
      %Trueskill.Variable{value: new_value, messages: %{sum: new_message, diff: Gaussian.new}}
    end)
  end

  def up(team_performances, performances, options) do
    addaptive = options[:team_performance_addaptive]
    Enum.zip(team_performances, performances)
      |> Enum.map(fn({team_performance, player_performances}) ->
        update_player_performance(team_performance, player_performances, addaptive)
      end)
  end

  defp update_player_performance(team_performance, player_performances, addaptive) do
    Enum.with_index(player_performances)
      |> Enum.map(fn({player_performance, idx}) ->
        rest_player_performances = List.delete_at(player_performances, idx)
        input_values = [team_performance.value|Enum.map(rest_player_performances, fn(x) -> 
          x.value end)]
        input_messages = [team_performance.messages.sum|Enum.map(rest_player_performances, fn(x) -> 
          x.messages.sum end)]
        coefficients = Enum.map(player_performances, fn(_) -> -1 end)
          |> List.replace_at(0, 1 * Enum.count(player_performances))
        [new_value, new_message] =
          sum(player_performance.value, player_performance.messages.sum, input_values, input_messages, coefficients)
        Trueskill.Variable.merge_message(:likelihood,
          %Trueskill.Variable{value: new_value, messages: %{sum: new_message}},
          player_performance
        )
      end)
  end

end
