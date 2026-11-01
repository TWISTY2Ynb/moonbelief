"""Reject MoonBit compiler versions below the acceptance minimum."""
import re
import subprocess
import sys


def main():
    result = subprocess.run(["moonc", "-v"], capture_output=True, text=True, check=True)
    version = result.stdout.strip()
    match = re.search(r"\bv(\d+)\.(\d+)\.(\d+)(?:[+\s]|$)", version)
    if match is None:
        print("Cannot verify moonc version: " + version, file=sys.stderr)
        return 1
    if tuple(map(int, match.groups())) < (0, 10, 16):
        print("moonc >= 0.10.16 is required; found " + version, file=sys.stderr)
        return 1
    print("Compiler minimum satisfied: " + version)
    return 0


if __name__ == "__main__":
    sys.exit(main())
