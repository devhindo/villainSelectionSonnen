# Example input for closest-first attack mode
input = """
{
  "attack_modes": [
    "closest-first"
  ],
  "radar": [
    {
      "position": {
        "x": 10,
        "y": 10
      },
      "villains": [
        {
          "costume": "Donald Duck"
        },
        {
          "costume": "Donald Duck"
        }
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
