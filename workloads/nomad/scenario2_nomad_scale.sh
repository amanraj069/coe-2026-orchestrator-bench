#!/usr/bin/env bash
set -euo pipefail

export NOMAD_ADDR="http://192.168.56.10:4646"
# Ensure a clean baseline for the scaling measurement.
nomad job stop -purge scaling-test >/dev/null 2>&1 || true
nomad job stop -purge hotel-reservation >/dev/null 2>&1 || true
nomad job run -detach /vagrant/workloads/nomad/scaling-test.nomad >/dev/null
# The submitted job already starts at count=1; wait briefly for deployment lock release.
sleep 20

set +e
/usr/bin/time -p nomad job scale scaling-test nginx 50 >/tmp/nomad_scale_monitor.log 2>/tmp/nomad_scale_time.log
scale_rc=$?
set -e

scale_seconds=$(awk '/^real / {print $2}' /tmp/nomad_scale_time.log)
echo "SCALE_SECONDS=${scale_seconds}"
echo "SCALE_EXIT_CODE=${scale_rc}"
echo "SCALE_SUMMARY=$(nomad job status scaling-test | awk '$1=="nginx" {print $0; exit}')"
nomad job status scaling-test | sed -n '1,36p'
