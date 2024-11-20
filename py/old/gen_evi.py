import json

data = [{
    "image": f"../../data/evidence/evidence_{i}.png",
    "palette": [15, 16, 32],
    "idx": i,
} for i in range(66)
]

with open("gen.json", "w") as f:
    json.dump(data, f, indent=4)
