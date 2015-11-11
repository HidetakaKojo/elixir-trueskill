defmodule Trueskill.Variable do
  defstruct [:value, :messages]

  def merge_message(key, %Trueskill.Variable{} = variable1, %Trueskill.Variable{} = variable2) do
    new_messages = Map.merge(variable1.messages, Map.take(variable2.messages, [key]))
    %Trueskill.Variable{value: variable1.value, messages: new_messages}
  end

  def merge_messages(key, list1, list2) do
    Enum.with_index(list1)
      |> Enum.map(fn({variable1, idx}) ->
        variable2 = Enum.fetch!(list2, idx)
        merge_message(key, variable1, variable2)
      end)
  end

  def to_rating(%Trueskill.Variable{} = variable) do
    Trueskill.Rating.new(variable.value.mu, variable.value.sigma)
  end
end
