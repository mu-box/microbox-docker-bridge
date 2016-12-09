# source docker helpers
. util/docker.sh

@test "Start Container" {
  start_container "openvpn-test"
}

@test "Verify openvpn installed" {
  # ensure openvpn executable exists
  run docker exec "openvpn-test" bash -c "[ -f /data/sbin/openvpn ]"

  [ "$status" -eq 0 ]
}

@test "Stop Container" {
  stop_container "openvpn-test"
}
