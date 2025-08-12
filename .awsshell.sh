##/usr/bin/env zsh

export REGION_CODE="ca-central-1"
export AWS_PAGER=""

color_bold_red='\033[1;31m'
color_bold_green='\033[1;32m'
color_bold_yellow='\033[1;33m'
color_bold_blue='\033[1;34m'
color_red='\033[1;31m'
color_green='\033[1;32m'
color_yellow='\033[1;33m'
color_blue='\033[1;34m'
color_reset='\033[0m'

echo_color () {
  local color="$1"; shift
  echo -e "${color}$*${color_reset}" >&2
}

ec2-list () {
  local raw_json_output
  raw_json_output="$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[{InstanceId:InstanceId},{Tags:Tags[*]}]')"
  for item in $( echo "${raw_json_output}" | jq -r '.[] | @base64'); do
    #echo ${item} >> /dev/stdout
    #echo ${item} | base64 --decode
    #echo >> /dev/stdout
    instanceId="$(echo "${item}" | base64 --decode | jq -r '.[0].[0].InstanceId')"
    tags="$(echo "${item}" | base64 --decode | jq -r '.[0].[1].Tags')"
    echo_color "${color_yellow}" "${instanceId}"
    for tag in $( echo "${tags}" | jq -r '.[] | @base64'); do
      key="$(echo "${tag}" | base64 --decode | jq -r '.Key')"
      value="$(echo "${tag}" | base64 --decode | jq -r '.Value')"
      printf "%-40s  %s\n" "${key}" "${value}" > /dev/stdout
    done
  done
}

aws-ssm() {
  local instance_name="$1"
  if [ "$#" -lt 1 ]; then
    echo 'Posisional argument [instance-name] is required.'
  fi
  proxy-on
  aws ssm start-session --target "$1" --region "${REGION_CODE}"
}

eks-refresh() {
  proxy-on
  aws eks update-kubeconfig --name Household-Ordering --region "${REGION_CODE}"
  proxy-off
}

aws-iam-switch-role() {
  if [ "$#" -ne 1 ]; then
    error "Missing mandatory argument - role-alias. Abort!"
  fi
  if [ "$1" = "uat" ]; then
    aws_role_arn="arn:aws:iam::273047853371:role/iacServiceAccess"
  elif [ "$1" = "prod" ]; then
    aws_role_arn="arn:aws:iam::392604688492:role/iacServiceAccess"
  elif [ "$1" = "devops" ]; then
    aws_role_arn="arn:aws:iam::744472556475:role/iacServiceAccess"
  elif [ "$1" = "dev" ]; then
    aws_role_arn="arn:aws:iam::806707732072:role/iacServiceAccess"
  elif [ "$1" = "gitlab-runner" ]; then
    aws_role_arn="arn:aws:iam::744472556475:role/gitlab-runner"
  else
    error "Invalid aws role alias [$1]. Abort!"
  fi
  json_output="$(aws sts assume-role --role-arn "${aws_role_arn}" --role-session-name cli-session --query "Credentials" --output json)"
  export AWS_ACCESS_KEY_ID="$(echo ${json_output} | jq -r .AccessKeyId)"
  export AWS_SECRET_ACCESS_KEY="$(echo ${json_output} | jq -r .SecretAccessKey)"
  export AWS_SESSION_TOKEN="$(echo ${json_output} | jq -r .SessionToken)"
}

iam_gitlab_runner() {
  proxy-on
  echo "switching role to gitlab-runner ..."
  aws_switch_role gitlab-runner
  echo "switching role to gitlab-runner - DONE"
  aws sts get-caller-indentity
}

aws_encrypt () {
  local input
  while IFS= read -r line || [ -n "$line" ]; do
    if [ -z "${input}" ]; then
      input="${line}"
    else
      input="${input}\n${line}"
    fi
  done
  proxy-on > /dev/null
  aws kms encrypt --key-id alias/hts-data-key --region ca-central-1 --plaintext "$(echo -n "${input}" | base64 -w0)" --output text --query CiphertextBlob
  proxy-off > /dev/null
}

aws_decrypt () {
  local ciphertext="$(cat)"
  proxy-on > /dev/null
  aws kms decrypt --key-id alias/hts-data-key --region ca-central-1 --ciphertext-blob "${ciphertext}" --output text --query Plaintext | base64 -d
  proxy-off > /dev/null
}
