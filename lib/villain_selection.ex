defmodule VillainSelection do

  @spec select(String.t()) :: {:ok, String.t()} | {:error, any()}
  def select(input) do
    IO.puts("Hello #{input}!")
  end
end

VillainSelection.select("sonnen")
