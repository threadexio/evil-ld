#!/usr/bin/env bash
set -eu -o pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

main() {
  cd "$SCRIPT_DIR"
  
  echo "using OCI runtime: ${RUNTIME:=docker}"
  echo "building image '${IMAGE:=localhost/evil-ld:test}'"
  echo

  $RUNTIME build -t "$IMAGE" -f ./Dockerfile .
  exec $RUNTIME run --rm --privileged -v $PWD/..:/shared -it "$IMAGE"
}

main "$@"
