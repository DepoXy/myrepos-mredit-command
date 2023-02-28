mredit — Locate and edit myrepos config fastly 🧜
=================================================

## DESCRIPTION

  Finds the [myrepos](https://myrepos.branchable.com/) config file for
  the current project, and opens it in Vim/GVim.

  (Please PR if you'd like to add support for your editor.)

## COMMANDS

  `mredit` opens the config in your terminal using Vim.

  `mropen` opens the config in a new or existing GVim window.

  Both commands will position the cursor at the start of the
  project's config.

## USE CASE

  If you manage multiple `myrepos` config files (e.g., I have all my Vim plugs
  in one set of files, Git projects in another, etc.), it can be annoying
  trying to locate the appropriate config file when you want to make a
  change.

  To make it easy to find and edit a project's `myrepos` config,
  you can use the two commands, `mredit` and `mropen`.

  The commands work by searching a pre-assembled directory of symlinks
  to your config files, based on what's listed in the `~/.mrtrust` file.

## SETUP

  Run `infuse-configlns` to generate the symlinks directory:

    cd path/to/myrepos-mredit-command
    ./bin/infuse-configlns

  The default location for the symlinks is `~/.mrconfiglns`, but
  you can change it using an environ, e.g.,:

    MREDIT_CONFIGS=~/.mrcfglns ./bin/infuse-configlns

  In which case you'll need to use the same `MREDIT_CONFIGS` path
  when you call `mredit` or `mropen`, so you might want to
  export it from your Bashrc or similar:

    export MREDIT_CONFIGS=~/.mrcfglns

## INSTALL

  You could put the `bin/` directory on PATH to use it conveniently.

  You can also run make install to add symlinks to `~/.local/bin`:

      $ PREFIX=~/.local make install

  This symlinks the two scripts back to the source repo, e.g.,:

      $ ls -la ~/.local/bin/mredit
      … ~/.local/bin/mredit -> /path/to/myrepos-mredit-command/bin/mredit

  Run `PREFIX=~/.local make uninstall` to remove both symlinks.

### GVim-Open-Kindness

  The `mropen` command prefers `gvim-open-kindness`
  if available, otherwise it falls back on raw `gvim` calls.

  - You can clone and install `gvim-open-kindness` from sources:

    https://github.com/DepoXy/gvim-open-kindness#🐬

  - The `gvim-open-kindness` command adds a few niceties, such
    as fronting GVim after opening the file (macOS and MATE).

  - If `gvim-open-kindness` is not installed, you will have to
    to manually switch to the GVim app if the opened file is
    sent to an existing GVim instance.

  Whether or not you install `gvim-open-kindness`, you can use the
  `GVIM_OPEN_SERVERNAME` environ to set the GVim `--servername`, e.g.,:

      GVIM_OPEN_SERVERNAME="my-gvim-server" mropen

## PREREQUISITES

  These commands require
  [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) and
  [`jq`](https://github.com/stedolan/jq).

  - Debian:

        sudo apt-get install jq rg

  - macOS:

        brew install jq rg 

## SEE ALSO

  Oh, My Repos! is a collection of `myrepos` command extensions and actions

  https://github.com/landonb/ohmyrepos#😤

## AUTHOR

**myrepos-mredit-command** is Copyright (c) 2020-2023 Landon Bouma &lt;depoxy@tallybark.com&gt;

This software is released under the MIT license (see `LICENSE` file for more)

## REPORTING BUGS

&lt;https://github.com/DepoXy/myrepos-mredit-command/issues&gt;

