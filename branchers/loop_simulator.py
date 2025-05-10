# loop_simulator.py

# Output: branch_trace.txt with lines like "25 1", "33 0"

OUTER_PC = 25  # Simulated PC address for outer loop (i < 1000)
INNER_PC = 33  # Simulated PC address for inner loop (j < 5)

def generate_branch_trace():
    with open("branch_trace.txt", "w") as f:
        for i in range(1000):
            # Outer loop branch (i < 1000) — always taken except final iteration
            f.write(f"{OUTER_PC} 1\n") if i < 999 else f.write(f"{OUTER_PC} 0\n")

            for j in range(6):  # 0 to 5 inclusive → 6 evaluations
                if j < 5:
                    f.write(f"{INNER_PC} 1\n")  # j < 5 is true (taken)
                else:
                    f.write(f"{INNER_PC} 0\n")  # j == 5 → false (not taken)

if __name__ == "__main__":
    generate_branch_trace()
    print("Generated branch_trace.txt with 6000 entries.")
