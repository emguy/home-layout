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

kaniko_docker_login () {
  echo "{\"auths\":{\"$DEV_IMAGE_REGISTRY\":{\"auth\":\"$(printf "%s:%s" "$UA_USER" "$UA_PASSWORD" | base64 | tr -d '\n')\"},\"$RELEASE_IMAGE_REGISTRY\":{\"auth\":\"$(printf "%s:%s" "$UA_USER" "$UA_PASSWORD" | base64 | tr -d '\n')\"}}}" > /kaniko/.docker/config.json
}
