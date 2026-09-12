#!/bin/bash -Eeu
readonly MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly REGEX="image_name\": \"(.*)\""
readonly JSON=`cat ${MY_DIR}/docker/image_name.json`
[[ ${JSON} =~ ${REGEX} ]]
readonly IMAGE_NAME="${BASH_REMATCH[1]}"

# Both versions are checked because the start-point's manifest.json states
# both, and docker/install.sh names no version for either. A floating
# dependency would otherwise move underneath a display_name that says
# otherwise. The compiler comes from the base image rather than from here,
# which is all the more reason to check it: nothing else in this repo would
# notice the base moving.
check_version()
{
  local -r what="${1}"
  local -r expected="${2}"
  local -r command="${3}"
  local -r actual=$(docker run --rm -i ${IMAGE_NAME} sh -c "${command}")

  if echo "${actual}" | grep -q "${expected}"; then
    echo "${what} VERSION CONFIRMED as ${expected}"
  else
    echo "${what} VERSION EXPECTED: ${expected}"
    echo "${what} VERSION   ACTUAL: ${actual}"
    exit 42
  fi
}

check_version vitest     5.0 '/etc/ts/node_modules/.bin/vitest --version'
check_version typescript 6.0 '/etc/ts/node_modules/.bin/tsc --version'
