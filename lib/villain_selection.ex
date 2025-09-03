defmodule VillainSelection do
  alias VillainSelection.AttackModes

  @spec select(String.t()) :: {:ok, String.t()} | {:error, any()}
  def select(input) do
    try do
      # Parse the input JSON
      with {:ok, data} <- Jason.decode(input),
           :ok <- validate_input(data),
           {:ok, result} <- process_data(data) do
        {:ok, result}
      else
        {:error, reason} -> {:error, reason}
      end
    rescue
      e -> {:error, "Error processing input: #{inspect(e)}"}
    end
  end

  defp validate_input(data) do

    # IO.inspect(data, label: "Input data")

    # Check if required fields exist
    with true <- Map.has_key?(data, "attack_modes"),
         true <- Map.has_key?(data, "radar"),
         true <- is_list(data["attack_modes"]),
         true <- is_list(data["radar"]),
         :ok <- validate_radar(data["radar"]),
         :ok <- AttackModes.validate_attack_modes(data["attack_modes"]) do
      :ok
    else
      false -> {:error, "Missing or invalid fields in input data"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_radar(radar) do
    # Validate each position in the radar data
    validation_results = Enum.map(radar, fn position ->
      with true <- Map.has_key?(position, "position"),
           true <- Map.has_key?(position, "villains"),
           true <- is_list(position["villains"]),
           true <- Map.has_key?(position["position"], "x"),
           true <- Map.has_key?(position["position"], "y"),
           :ok <- validate_villains(position["villains"]) do
        :ok
      else
        false -> {:error, "Invalid position data structure"}
        error -> error
      end
    end)

    if Enum.all?(validation_results, fn result -> result == :ok end) do
      :ok
    else
      first_error = Enum.find(validation_results, fn result -> result != :ok end)
      first_error
    end
  end

  defp validate_villains(villains) do
    # Validate each villain in the list
    validation_results = Enum.map(villains, fn villain ->
      with true <- Map.has_key?(villain, "costume"),
           true <- villain["costume"] != nil,
           :ok <- validate_malice(villain) do
        :ok
      else
        false -> {:error, "Invalid villain data"}
        error -> error
      end
    end)

    if Enum.all?(validation_results, fn result -> result == :ok end) do
      :ok
    else
      first_error = Enum.find(validation_results, fn result -> result != :ok end)
      first_error
    end
  end

  defp validate_malice(villain) do
    # Malice is optional for Donald Duck but should be valid if present
    if Map.has_key?(villain, "malice") do
      malice = villain["malice"]
      cond do
        not is_number(malice) -> {:error, "Malice must be a number"}
        malice < 0 or malice > 100 -> {:error, "Malice must be between 0 and 100"}
        true -> :ok
      end
    else
      if villain["costume"] == "Donald Duck" do
        :ok
      else
        :ok
      end
    end
  end

  defp process_data(data) do

    attack_modes = data["attack_modes"]
    radar = data["radar"]

    # Check if we need to prioritize Vader for sorting villains
    prioritize_vader = Enum.member?(attack_modes, "prioritize-vader")

    # Apply attack modes to filter and sort radar data
    processed_radar = AttackModes.apply_attack_modes(radar, attack_modes)

    case processed_radar do
      [] -> {:error, "No valid targets after applying attack modes"}
      [first_position | _] ->
        # Extract the first position after applying all attack modes
        villains = AttackModes.extract_villains_sorted_by_malice(first_position, prioritize_vader)

        if Enum.empty?(villains) do
          {:error, "No valid villains in selected position"}
        else
          # Prepare the result
          result = %{
            "position" => first_position["position"],
            "villains" => villains
          }

          # Convert result to JSON string
          {:ok, Jason.encode!(result)}
        end
    end
  end
end
