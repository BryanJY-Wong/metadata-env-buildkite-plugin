#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

@test "Exports metadata to env" {
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_0="FOO"
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_1="BAR"

  stub buildkite-agent \
    "meta-data get FOO : echo BAR" \
    "meta-data get BAR : echo TENDER"

  run $PWD/hooks/environment

  assert_success
  assert_output --partial "FOO=(3 chars)"
  assert_output --partial "BAR=(6 chars)"
}

@test "Exports remapped meta-data to env" {
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_0="foo-meta=FOO_ENV"
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_1="BAR"

  stub buildkite-agent \
    "meta-data get foo-meta : echo FIRST" \
    "meta-data get BAR : echo SECOND" \

  run $PWD/hooks/environment

  assert_success
  assert_output --partial "FOO_ENV=(5 chars)"
  assert_output --partial "BAR=(6 chars)"
}

@test "Env and meta-data and default values are assigned" {
  source $PWD/hooks/environment

  run source $PWD/hooks/environment; eval "$(split_key_item "META;")"
  assert_success
  assert_output "meta_data_key=\"META\" mapped_key=\"META\" default_val=\"\""

  run source $PWD/hooks/environment; eval "$(split_key_item "META")"
  assert_success
  assert_output "meta_data_key=\"META\" mapped_key=\"META\" default_val=\"\""

  run source $PWD/hooks/environment; eval "$(split_key_item "meta=META")"
  assert_success
  assert_output "meta_data_key=\"meta\" mapped_key=\"META\" default_val=\"\""

  run source $PWD/hooks/environment; eval "$(split_key_item "meta=META;")"
  assert_success
  assert_output "meta_data_key=\"meta\" mapped_key=\"META\" default_val=\"\""

  run source $PWD/hooks/environment; eval "$(split_key_item "meta=META;data")"
  assert_success
  assert_output "meta_data_key=\"meta\" mapped_key=\"META\" default_val=\"data\""

  run source $PWD/hooks/environment; eval "$(split_key_item "META;data")"
  assert_success
  assert_output "meta_data_key=\"META\" mapped_key=\"META\" default_val=\"data\""
}