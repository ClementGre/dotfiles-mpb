# dotfiles-mbp

My nix-darwin dotfiles for my personal MacBook Pro.

## Commands

Common tasks are [just](https://github.com/casey/just) recipes. List them with:
```bash
just
```

- `just switch` rebuilds without upgrading brew packages; `just upgrade` also runs brew update/upgrade and re-applies custom icons.
- Custom icons (`just icons`) and file associations (`just assoc`) no longer run on every rebuild.

## Dotfiles are live symlinks

`home.nix` links the shell, skhd, fastfetch and sketchybar configs straight to `files/` in this repo (`mkOutOfStoreSymlink`), so edits apply without a rebuild. Nix rollbacks don't restore them: git is their history. The repo must stay at `~/GitHub/dotfiles-MBP`.

After editing `files/sketchybar/helpers/*.c`, run `just bar` to rebuild the helpers and reload sketchybar.
