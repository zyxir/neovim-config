#!/usr/bin/env python3
"""Package or install this Neovim config for offline transfer (cross-platform).

USAGE
  python3 scripts/transfer.py bundle    # create neovim-config-offline.tar.gz
  python3 scripts/transfer.py install   # extract into Neovim directories

Run `bundle` on a machine with internet access (macOS / Linux / Windows).
Copy the resulting .tar.gz + this script to the target machine and run
`install`.  Existing config is backed up automatically.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

BUNDLE_NAME = "neovim-config-offline.tar.gz"


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

def fail(msg: str) -> None:
    print(f"\033[31mERROR: {msg}\033[0m", file=sys.stderr)
    sys.exit(1)


def info(msg: str) -> None:
    print(f"\033[36m{msg}\033[0m")


def green(msg: str) -> None:
    print(f"\033[32m{msg}\033[0m")


def yellow(msg: str) -> None:
    print(f"\033[33m{msg}\033[0m")


def is_windows() -> bool:
    return sys.platform == "win32"


def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, check=True, text=True, **kwargs)


# ---------------------------------------------------------------------------
# platform-aware Neovim paths
# ---------------------------------------------------------------------------

def _nvim_config_dir() -> Path:
    """Neovim config directory for the current platform."""
    if is_windows():
        return Path(os.environ["LOCALAPPDATA"]) / "nvim"
    return Path.home() / ".config" / "nvim"


def _nvim_data_dir() -> Path:
    """Neovim data directory (plugin cache lives under <data>/lazy)."""
    if is_windows():
        return Path(os.environ["LOCALAPPDATA"]) / "nvim-data"
    return Path.home() / ".local" / "share" / "nvim"


def _nvim_plugin_cache() -> Path:
    return _nvim_data_dir() / "lazy"


# ---------------------------------------------------------------------------
# bundle
# ---------------------------------------------------------------------------

def cmd_bundle() -> None:
    """Create a self-contained tarball of the config + lazy plugin cache."""

    repo = Path(__file__).resolve().parent.parent
    lazy_dir = _nvim_plugin_cache()

    if not lazy_dir.is_dir():
        fail(f"Plugin cache not found: {lazy_dir}\n"
             f"Run Neovim with internet access first so lazy.nvim clones plugins.")

    info(f"Config:  {repo}")
    info(f"Plugins: {lazy_dir}")

    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        config_dest = tmp / "config"
        plugins_dest = tmp / "lazy"

        shutil.copytree(
            repo,
            config_dest,
            ignore=shutil.ignore_patterns(".git", "*.tar.gz", "__pycache__"),
            dirs_exist_ok=True,
        )

        info("Copying plugin cache …")
        shutil.copytree(lazy_dir, plugins_dest, dirs_exist_ok=True, symlinks=True)

        bundle_path = repo / BUNDLE_NAME
        info(f"Creating {bundle_path} …")
        with tarfile.open(bundle_path, "w:gz") as tar:
            tar.add(config_dest, arcname="config")
            tar.add(plugins_dest, arcname="lazy")

        size_mb = bundle_path.stat().st_size / (1024 * 1024)
        green(f"Done: {bundle_path} ({size_mb:.0f} MB)")

    print()
    print("Copy this file + the .tar.gz to the target machine, then:")
    print(f"  python scripts{os.sep}transfer.py install")


# ---------------------------------------------------------------------------
# install
# ---------------------------------------------------------------------------

def cmd_install() -> None:
    """Extract the bundle into the correct Neovim directories."""

    script_dir = Path(__file__).resolve().parent
    bundle = script_dir.parent / BUNDLE_NAME

    if not bundle.is_file():
        fail(f"Bundle not found: {bundle}\n"
             f"Copy {BUNDLE_NAME} alongside this script first.")

    # verify Neovim
    nvim = shutil.which("nvim")
    if not nvim:
        fail("Neovim not found on PATH — install it first")
    version = run(["nvim", "--version"], stdout=subprocess.PIPE).stdout.splitlines()[0]
    green(f"Neovim: {version}")

    config_dir = _nvim_config_dir()
    lazy_dir = _nvim_plugin_cache()

    # backup
    if config_dir.exists():
        backup = config_dir.with_name(f"nvim.bak.{config_dir.stat().st_mtime:.0f}")
        yellow(f"Backing up {config_dir} → {backup}")
        if backup.exists():
            shutil.rmtree(backup)
        shutil.move(str(config_dir), str(backup))

    config_dir.mkdir(parents=True, exist_ok=True)
    lazy_dir.mkdir(parents=True, exist_ok=True)

    # extract
    size_mb = bundle.stat().st_size / (1024 * 1024)
    info(f"Extracting ({size_mb:.0f} MB) …")

    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        with tarfile.open(bundle, "r:gz") as tar:
            tar.extractall(tmp)

        # config files
        bundled_config = tmp / "config"
        if bundled_config.is_dir():
            for item in bundled_config.iterdir():
                dest = config_dir / item.name
                if dest.exists():
                    shutil.rmtree(dest) if dest.is_dir() else dest.unlink()
                shutil.move(str(item), str(dest))

        # plugin cache
        bundled_lazy = tmp / "lazy"
        if bundled_lazy.is_dir():
            if lazy_dir.exists():
                shutil.rmtree(lazy_dir)
            shutil.move(str(bundled_lazy), str(lazy_dir))

    green(f"Installed → {config_dir}")

    # post-install
    print()
    print("Next steps in Neovim:")
    yellow("  :Lazy build blink.cmp")
    yellow("  :checkhealth")
    print()
    print("Fonts:")
    yellow("  JetBrainsMono Nerd Font Mono from https://www.nerdfonts.com")


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def main() -> None:
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    cmd = sys.argv[1]
    if cmd == "bundle":
        cmd_bundle()
    elif cmd == "install":
        cmd_install()
    else:
        print(f"Unknown command: {cmd}")
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()
