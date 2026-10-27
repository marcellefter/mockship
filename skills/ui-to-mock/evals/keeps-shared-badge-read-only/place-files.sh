#!/usr/bin/env bash
set -eu
root=$(cd "$(dirname "$0")/../../../.." && pwd)
bash "$root/examples/scaffold.sh" - -
