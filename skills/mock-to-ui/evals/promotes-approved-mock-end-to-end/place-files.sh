#!/usr/bin/env bash
set -eu
root=$(cd "$(dirname "$0")/../../../.." && pwd)
bash "$root/examples/scaffold.sh" "$root/examples/overlays/api-complete" "$root/examples/overlays/invoices-mock"
