#!/usr/bin/env bash
# vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=bash
# Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
# Project: https://github.com/DepoXy/myrepos-mredit-command#🧜
# License: MIT

# Copyright (c) © 2020-2023 Landon Bouma. All Rights Reserved.

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

remove_symlink_hierarchy_safe () {
  if [ -n "$(find . -maxdepth 1 ! -type l ! -type d)" ]; then
    warn "Symlink hierarchy target exists but contains regular files"
    warn "- Please inspect yourself and try again: $(pwd -L)"

    # Triggers errexit.
    return 1
  fi

  # Remove symlinks.
  find . -type l -exec /bin/rm {} +

  # Remove now-empty directories.
  local subdir
  find . ! -path . -type d | tac | while read -r subdir; do
    /bin/rmdir "${subdir}"
  done

  return 0
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

deep_link () {
  local source="$1"
  local warn_cmd="${2:-echo}"

  # Build the hierarchy.
  local relative_dir
  relative_dir="$(dirname "${source}" | sed 's#^/##')"

  mkdir -p "${relative_dir}"

  # Make the symlink.
  local config_file
  config_file="$(basename "${source}")"

  local target="${relative_dir}/${config_file}"

  /bin/ln -s "${source}" "${target}"

  # `ln` happily makes symlink to non-existent target, which we
  # will allow (which is a Good Thing, e.g., `rg` complains on
  # broken links, which'll alert user to the problem). But we'll
  # also check ourselves, to be proactive.
  if [ -e "${source}" ]; then
    let 'INFUSE_SYMLINKS_CNT += 1'
  else
    let 'INFUSE_SYMLINKS_NOK += 1'

    >&2 ${warn_cmd} "WARN: Phantom target symlinked: ${source}"
    >&2 ${warn_cmd} "- You'll see broken symlink at: $(pwd)/${target}"
  fi
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

