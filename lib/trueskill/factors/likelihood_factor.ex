defmodule Trueskill.Factors.LikelihoodFactor do
  alias Trueskill.Gaussian.Distribution, as: Gaussian
  alias Trueskill.Variable

  @beta 25.0/6

  def down(skills) do
    down(skills, %{})
  end
  def down(skills, %{} = options) do
    beta = options[:beta] || @beta
    Enum.map(skills, fn(skill) ->
      Enum.map(skill, fn(player_skill) ->
        [new_value, new_message] = update(Gaussian.new, Gaussian.new, player_skill, Gaussian.new, beta)
        %Trueskill.Variable{value: new_value, messages: %{likelihood: new_message, sum: Gaussian.new}}
      end)
    end)
  end

  def up(team_skills, team_performances) do
    up(team_skills, team_performances, %{})
  end
  def up(team_skills, team_performances, options) do
    beta = options[:beta] || @beta
    Enum.zip(team_skills, team_performances)
      |> Enum.map(fn({player_skills, player_performances}) ->
        Enum.zip(player_skills, player_performances)
          |> Enum.map(fn({skill, performance}) ->
            [new_value, new_message] = update(skill, Gaussian.new, performance.value, performance.messages.likelihood, beta)
            new_value
          end)
      end)
  end

  def update(output_value, output_message, input_value, input_message, beta) do
    normal = Gaussian.new
    diff_pi = input_value.pi - input_message.pi
    diff_tau = input_value.tau - input_message.tau
    alpha = 1.0 / (1.0 + (:math.pow(beta, 2) * diff_pi))
    new_message = Gaussian.new_with_precision((diff_tau/diff_pi), (alpha*diff_pi))
    new_value = Gaussian.divide(output_value, output_message)
      |> Gaussian.multiply(new_message)
    [new_value, new_message]
  end

end
