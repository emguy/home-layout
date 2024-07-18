#!/usr/bin/env zsh

color_bold_red='\033[1;31m'
color_bold_green='\033[1;32m'
color_bold_yellow='\033[1;33m'
color_bold_blue='\033[1;34m'
color_red='\033[1;31m'
color_green='\033[1;32m'
color_yellow='\033[1;33m'
color_blue='\033[1;34m'
color_reset='\033[0m'

log_info () {
  echo -e "${color_bold_yellow}[INFO] $*${color_reset}" >&2
}

log_task () {
  echo -e "${color_bold_blue}[TASK] $*${color_reset}" >&2
}

log_warn () {
  echo -e "${color_bold_yellow}[WARNING] $1${color_reset}" >&2
}

log_error () {
  echo -e "${color_bold_red}[ERROR] $1${color_reset}" >&2
}

error () {
  log_error "$1"
  exit 1
}

generate_self_assigned_certs () {
  local fqdn="$1"
  openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout out.key -out out.crt -subj "/CN=${fqdn}" -addext "subjectAltName=DNS:${fqdn}"
  echo 'Use the following codesnippet to generate k8s secret for tls'
  echo 'kubectl create secret tls my-tls-secret --cert=path/to/cert/file --key=path/to/key/file'
}

check_prog () {
  local _msg="$2"
  test -n "${_msg}" || _msg="Unable to find a reachable executable '${1}'"
  command -v "${1}" > /dev/null 2> /dev/null || error "${_msg}"
}

setup_podman_socket () {
  set -x
  target_path="$(echo "${DOCKER_HOST}" | sed 's;^unix://\(.*\)$;\1;')"
  if [ -f "${target_path}" ]; then
    rm -f "${target_path}"
  fi
  conn="$(podman system connection ls | sed -n 's/\(.*true$\)/\1/p')"
  user="$(echo "${conn}" | sed 's;.*\sssh://\(.*\)@.*:[0-9]*/run.*true$;\1;')"
  port_number="$(echo "${conn}" | sed 's;.*\sssh://.*@.*:\([0-9]*\)/run.*true$;\1;')"
  socket_path="$(echo "${conn}" | sed 's;.*\sssh://.*@.*:[0-9]*\(/run.*/podman\.sock\).*true$;\1;')"
  ssh_identity="$(echo "${conn}" | awk '{ print $3 }' )"
  ssh -fnNT -L"${target_path}:${socket_path}" -i "${ssh_identity}" "ssh://${user}@localhost:${port_number}" -o StreamLocalBindUnlink=yes
  echo "${DOCKER_HOST} is regenerated !"
}

new_git_branch () {
  branch="feature/auto-$(gdate +%T.%N | md5 | head -c8)"
  git reset --hard
  git checkout main
  git pull
  git checkout -b "$branch"
}
