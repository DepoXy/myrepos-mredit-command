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

link_deep () {
  local source="$1"
  local target="$2"

  # Verify the source is complete path.
  local source_valid=false
  # COPYD: https://unix.stackexchange.com/a/256441/388857
  case "${source}" in (/*) pathchk -- "${source}";; (*) ! : ;; esac \
    && source_valid=true

  if ! ${source_valid}; then
    >&2 warn "Cannot link_deep relative path: ${source}"

    return 1
  fi

  # Build the hierarchy.
  local relative_dir
  local target
  if [ -z "${target}" ]; then
    # If the source is under home, normalize the user home prefix,
    # so implementations don't have to care what user is active
    # (mostly useful for tailoring an .ignore file for the deep-link
    # hierarchy).
    relative_dir="$(echo "${source}" | sed "s#^${HOME}/#/home/user/#")"

    # Strip leading delimiter to make relative path.
    relative_dir="$(dirname -- "${relative_dir}" | sed 's#^/##')"

    # Determine the target path within the relative subdirectory.
    local target_file
    target_file="$(basename -- "${source}")"

    target="${relative_dir}/${target_file}"
  else
    relative_dir="$(dirname -- "${target}")"
  fi

  mkdir -p "${relative_dir}"

  # In lieu of GNU `ln -sT` or BSD `ln -sh`, which won't follow
  # an existing target symlink, check ourselves if target exists.
  # - This is because default symlink behavior follows target links,
  #   e.g., if you ran the following:
  #     $ mkdir /tmp/ln-test && cd /tmp/ln-test &&
  #       mkdir bar && ln -s bar foo && ln -s bar foo
  #   you'd end up with the symlink you want, `foo -> bar/`, but
  #   also a symlink you probably don't want, `bar/bar -> bar`.
  # - In contrast:
  #     $ mkdir /tmp/ln-test && cd /tmp/ln-test &&
  #       mkdir bar && ln -sT bar foo && ln -sT bar foo
  #   creates just `foo -> bar/` and then prints:
  #     ln: failed to create symbolic link 'foo': File exists
  if [ -h "${target}" ]; then
    if [ "$(realpath -- "${target}")" = "$(realpath -- "${source}")" ]; then
      info " File already symlink: $(fg_lightred)$(pwd)/${target}$(attr_reset)"
    else
      >&2 warn "Target already exists: $(pwd)/${target}"
      >&2 warn "- New source: ${source}"
      >&2 warn "- Old source: $(realpath -- "${source}")"
    fi
  elif [ -e "${target}" ]; then
    >&2 warn "Nonlink target exists: $(pwd)/${target}"
    >&2 warn "- For source: ${source}"
  else
    info " $(fg_lightcyan)Created$(attr_reset)" \
      "$(attr_emphasis)deep$(attr_reset) symlink" \
      "$(fg_lightorange)$(pwd)/${target}$(attr_reset)"

    /bin/ln -s "${source}" "${target}"
  fi

  # `ln` happily makes symlink to non-existent target, which we
  # will allow (which is a Good Thing, e.g., `rg` complains on
  # broken links, which'll alert user to the problem). But we'll
  # also check ourselves, to be proactive.
  if [ -e "${source}" ]; then
    let 'INFUSE_SYMLINKS_CNT += 1'
  else
    let 'INFUSE_SYMLINKS_NOK += 1'

    >&2 warn "Phantom target symlinked: ${source}"
    >&2 warn "- You'll see broken symlink at: $(pwd)/${target}"
  fi
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

