#!/usr/bin/env python3
"""
Opens visidata in a tmux popup with a DataFrame.
Usage:
    python vd-popup.py --data-file <path>
    python vd-popup.py --pickle-file <path>
    python vd-popup.py --json-string <json>
"""

import argparse
import json
import os
import subprocess
import sys
import tempfile


def open_visidata_tmux(source_file):
    """Open visidata in a tmux popup window."""

    # Tmux popup command
    cmd = [
        "tmux",
        "popup",
        "-d",
        "#{pane_current_path}",
        "-w",
        "80%",
        "-h",
        "70%",
        "-E",  # Don't keep tmux session alive
        f"visidata {source_file}",
    ]

    subprocess.run(cmd)


def main():
    parser = argparse.ArgumentParser(description="Open visidata in tmux popup")
    parser.add_argument("--data-file", help="Path to data file (csv, parquet, etc.)")
    parser.add_argument("--pickle-file", help="Path to pickled pandas DataFrame")
    parser.add_argument("--json-string", help="JSON string of data")
    parser.add_argument(
        "--pickle-stdin", action="store_true", help="Read pickle from stdin"
    )

    args = parser.parse_args()

    # Create temp file for visidata to read
    with tempfile.NamedTemporaryFile(mode="w", suffix=".csv", delete=False) as f:
        temp_file = f.name

    try:
        # Convert input to temp file
        if args.data_file:
            # Just use the file directly (copy or symlink)
            temp_file = args.data_file

        elif args.pickle_file:
            import pandas as pd

            df = pd.read_pickle(args.pickle_file)
            df.to_csv(temp_file, index=False)

        elif args.json_string:
            import pandas as pd

            df = pd.read_json(args.json_string)
            df.to_csv(temp_file, index=False)

        elif args.pickle_stdin:
            import pickle
            import sys

            df = pickle.load(sys.stdin.buffer)
            df.to_csv(temp_file, index=False)

        # Open in tmux popup
        open_visidata_tmux(temp_file)

    finally:
        # Cleanup temp file (unless it was original file)
        if os.path.exists(temp_file) and temp_file != args.data_file:
            os.unlink(temp_file)


if __name__ == "__main__":
    main()
