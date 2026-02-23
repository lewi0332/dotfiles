import os
import subprocess
import tempfile

import pandas as pd
from IPython.core.magic import register_line_magic


@register_line_magic
def vd(line):
    """Open DataFrame in visidata (tmux popup version).

    Usage:
        %vd df           # Opens DataFrame 'df' in visidata
        %vd df --popup  # Force tmux popup (default)
    """
    import IPython

    ipython = IPython.get_ipython()

    # Get the DataFrame from user namespace
    df = ipython.user_ns.get(line.strip(), None)

    if df is None:
        print(f"Error: '{line.strip()}' not found in namespace")
        return

    if not isinstance(df, pd.DataFrame):
        print(f"Error: '{line.strip()}' is not a pandas DataFrame")
        return

    # Save to temp file
    with tempfile.NamedTemporaryFile(mode="w", suffix=".csv", delete=False) as f:
        temp_file = f.name

    df.to_csv(temp_file, index=False)

    # Open in tmux popup
    subprocess.run(
        [
            "tmux",
            "popup",
            "-d",
            os.getcwd(),
            "-w",
            "80%",
            "-h",
            "70%",
            "-E",
            f"visidata {temp_file}",
        ]
    )

    print(f"Opened in visidata popup: {temp_file}")


"""
Option 1: Add to dotfiles + symlink
- Store vd_popup.py in ~/dotfiles/scripts/
- Symlink it: ln -s ~/dotfiles/scripts/vd_popup.py ~/.ipython/profile_default/startup/vd_popup.py
- Your install script would create the symlink
"""
