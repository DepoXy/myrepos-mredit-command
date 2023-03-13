#!/usr/bin/env bash
# vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=bash
# Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
# Project: https://github.com/DepoXy/myrepos-mredit-command#🧜
# License: MIT

# Copyright (c) © 2020-2023 Landon Bouma. All Rights Reserved.

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #


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

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #

main () {
  deep_link "$@"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# Only run when executed; no-op when sourced.
if [ "$0" = "${BASH_SOURCE}" ]; then
  main "$@"
fi

