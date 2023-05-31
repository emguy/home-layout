function generate_self_assigned_certs() {
  local fqdn="$1"
  openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout out.key -out out.crt -subj "/CN=${fqdn}" -addext "subjectAltName=DNS:${fqdn}"
  echo 'Use the following codesnippet to generate k8s secret for tls'
  echo 'kubectl create secret tls my-tls-secret --cert=path/to/cert/file --key=path/to/key/file'
}

