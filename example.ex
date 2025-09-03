# Example input for closest-first attack mode
input = """
{
  "attack_modes": [
    "prioritize-vader"
  ],
  "radar": [
    {
      "position": {
        "x": 5,
        "y": 5
      },
      "villains": [
        {
          "costume": "Darth Vader",
          "malice": 95
        },
        {
          "costume": "Stormtrooper",
          "malice": 30
        }
      ]
    },
    {
      "position": {
        "x": 15,
        "y": 15
      },
      "villains": [
        {
          "costume": "Joker",
          "malice": 80
        },
        {
          "costume": "Captain Hook",
          "malice": 60
        }
      ]
    },
    {
      "position": {
        "x": 8,
        "y": 6
      },
      "villains": [
        {
          "costume": "Darth Vader",
          "malice": 100
        },
        {
          "costume": "Emperor",
          "malice": 90
        },
        {
          "costume": "Boba Fett",
          "malice": 70
        }
      ]
    },
    {
      "position": {
        "x": 20,
        "y": 25
      },
      "villains": [
        {
          "costume": "Voldemort",
          "malice": 85
        },
        {
          "costume": "Sauron",
          "malice": 95
        }
      ]
    },
    {
      "position": {
        "x": 3,
        "y": 4
      },
      "villains": [
        {
          "costume": "Darth Vader",
          "malice": 88
        },
        {
          "costume": "Kylo Ren",
          "malice": 75
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
