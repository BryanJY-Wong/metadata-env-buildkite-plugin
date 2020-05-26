#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

@test "Exports metadata to env" {
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_0="FOO"
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_1="BAR"

  stub buildkite-agent \
    "meta-data get FOO --default \"\": echo BAR" \
    "meta-data get BAR --default \"\": echo TENDER"

  run $PWD/hooks/environment

  assert_success
  assert_output --partial "FOO=BAR"
  assert_output --partial "BAR=TENDER"
}

@test "Exports remapped meta-data to env" {
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_0="foo-meta=FOO_ENV"
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_1="BAR"
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_2="meta=META;data"

  stub buildkite-agent \
    "meta-data get foo-meta --default \"\": echo FIRST" \
    "meta-data get BAR --default \"\": echo SECOND" \
    "meta-data get meta --default \"data\": echo data" 

  run $PWD/hooks/environment

  assert_success
  assert_output --partial "FOO_ENV=FIRST"
  assert_output --partial "BAR=SECOND"
  assert_output --partial "META=data"
}