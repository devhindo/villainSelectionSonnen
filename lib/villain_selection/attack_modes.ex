defmodule VillainSelection.AttackModes do
  @moduledoc """
  Module containing different attack mode strategies for the villain selection system.
  """

  @doc """
  Filter radar data based on the 'avoid-crossfire' mode.
  Removes any positions that have Donald Duck present.
  """
  def apply_avoid_crossfire(radar_data) do
    Enum.reject(radar_data, fn position ->
      Enum.any?(position["villains"], fn villain ->
        villain["costume"] == "Donald Duck"
      end)
    end)
  end

  @doc """
  Sort radar data by distance to origin (0,0) in ascending order.
  Used for 'closest-first' mode.
  """
  def apply_closest_first(radar_data) do
    Enum.sort_by(radar_data, fn position ->
      x = position["position"]["x"]
      y = position["position"]["y"]
      :math.sqrt(x * x + y * y)
    end)
  end

  @doc """
  Sort radar data by distance to origin (0,0) in descending order.
  Used for 'furthest-first' mode.
  """
  def apply_furthest_first(radar_data) do
      radar_data
      |> apply_closest_first()
      |> Enum.reverse()
  end

# we can also use sorting similar to apply_closest_first but I applied the DRY princple (note: it's not more effcient but less code - TBD)
#
#    Enum.sort_by(radar_data, fn position ->
#      x = position["position"]["x"]
#      y = position["position"]["y"]
#      :math.sqrt(x * x + y * y)
#    end, :desc)
#


  @doc """
  Filter radar data to prioritize positions with Darth Vader.
  If Darth Vader is present in any position, only return those positions.
  """
  def apply_prioritize_vader(radar_data) do
    positions_with_vader = Enum.filter(radar_data, fn position ->
      Enum.any?(position["villains"], fn villain ->
        villain["costume"] == "Darth Vader"
      end)
    end)
    if Enum.empty?(positions_with_vader), do: radar_data, else: positions_with_vader
  end

  @doc """
  Extract villain names from a position, sorted by malice (descending)
  and prioritizing Darth Vader if needed
  """
  def extract_villains_sorted_by_malice(position, prioritize_vader \\ false) do
    villains = position["villains"]
    |> Enum.filter(fn villain -> Map.has_key?(villain, "costume") end)
    |> Enum.filter(fn villain -> villain["costume"] != "Donald Duck" end)

    sorted_villains = if prioritize_vader do
      # Sort by Darth Vader first, then by malice
      Enum.sort_by(villains, fn villain ->
        is_vader = if villain["costume"] == "Darth Vader", do: 0, else: 1
        {is_vader, -Map.get(villain, "malice", 0)}
      end)
    else
      # Sort only by malice
      Enum.sort_by(villains, fn villain ->
        Map.get(villain, "malice", 0)
      end, :desc)
    end
    Enum.map(sorted_villains, fn villain -> villain["costume"] end)
  end

  @doc """
  Validate attack modes to make sure they are supported and not conflicting
  """
  def validate_attack_modes(attack_modes) do
    supported_modes = ["closest-first", "furthest-first", "avoid-crossfire", "prioritize-vader"]

    # Check if all modes are supported
    all_supported = Enum.all?(attack_modes, fn mode -> mode in supported_modes end)

    # Check for conflicting modes
has_conflicts = Enum.member?(attack_modes, "closest-first") && Enum.member?(attack_modes, "furthest-first")

    cond do
      !all_supported -> {:error, "Unsupported attack mode provided"}
      has_conflicts -> {:error, "Conflicting attack modes: closest-first and furthest-first"}
      true -> :ok
    end
  end

  @doc """
  Sort positions by the maximum malice value of villains in each position
  """
  def sort_by_malice(radar_data) do
    Enum.sort_by(radar_data, fn position ->
      position["villains"]
      |> Enum.map(fn villain -> Map.get(villain, "malice", 0) end)
      |> Enum.max(fn -> 0 end)
    end, :desc)
  end

  @doc """
  Apply the provided attack modes in sequence to the radar data

  The order of applying modes matters:
  1. First filter out positions with Donald Duck if avoid-crossfire is specified
  2. Then sort positions by distance (closest/furthest) or by max malice if no distance mode
  3. Finally apply Vader priority if needed
  """
  def apply_attack_modes(radar_data, attack_modes) do
    # First apply avoid-crossfire if it's in the modes
    data = if Enum.member?(attack_modes, "avoid-crossfire") do
      apply_avoid_crossfire(radar_data)
    else
      radar_data
    end

    # Get position sorting mode
    has_closest = Enum.member?(attack_modes, "closest-first")
    has_furthest = Enum.member?(attack_modes, "furthest-first")

    # Apply position sorting
    data = cond do
      has_closest -> apply_closest_first(data)
      has_furthest -> apply_furthest_first(data)
      true -> sort_by_malice(data)  # Default sorting by malice
    end

    # Finally, apply vader priority if needed
    if Enum.member?(attack_modes, "prioritize-vader") do
      apply_prioritize_vader(data)
    else
      data
    end
  end
end
