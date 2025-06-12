verbose = 0

def printv(*str, param="", v=0, sep=" ", end="\n", flush=False):
    global verbose, error
    if v > verbose:
        return

    if "e" in param:
        print("\033[31m", end="", flush=flush)
        error = True
    if "w" in param:
        print("\033[33m", end="", flush=flush)
    if "i" in param:
        print("\033[34m", end="", flush=flush)

    for s in str:
        print(s, end=sep, flush=flush)

    if "w" in param or "e" in param or "i" in param:
        print("\033[0m", end="", flush=flush)
    print("", end=end)
