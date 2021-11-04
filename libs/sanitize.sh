#!/usr/bin/env bash

sanitize () {
  local sanitized=()
  for token; do
    sanitized+=( "$(printf '%q' "$token")" )
  done
  printf '%s\n' "${sanitized[*]}"
}

run_sanitized () {
    __script_cmd=($@)
    eval "$( sanitize "${__script_cmd[@]}" )"
}
