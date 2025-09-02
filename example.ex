# Example input for closest-first attack mode
input = """
{
  "attack_modes": ["closest-first"],
  "radar": [
    {
      "position": {"x": 10, "y": 20},
      "villains": [
        {"costume": "Joker", "malice": 85},
        {"costume": "Penguin", "malice": 70}
      ]
    },
    {
      "position": {"x": 10, "y": 10},
      "villains": [
        {"costume": "Darth Vader", "malice": 95},
        {"costume": "Magneto", "malice": 80}
      ]
    }
  ]
}
"""

# Call the function and print the result
case VillainSelection.select(input) do
  {:ok, result} -> IO.puts("SUCCESS! Selected position and villains: #{result}")
  {:error, reason} -> IO.puts("ERROR: #{reason}")
end
