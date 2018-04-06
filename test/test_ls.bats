#!/usr/bin/env ./libs/bats/bin/bats

load './libs/bats-support/load'
load './libs/bats-assert/load'
load './helper'

@test "list from file" {
  run ${TFMINE} ls -f ${PLANS}/long
  assert_success
  run sh -c '${TFMINE} ls -f ${PLANS}/long | wc -l'
  assert_success
  assert_output "35"
}

@test "list from stdin" {
  run sh -c 'cat ${PLANS}/long | ${TFMINE} ls'
  assert_success
  run sh -c 'cat ${PLANS}/long | ${TFMINE} ls | wc -l'
  assert_success
  assert_output "35"
}

@test "list with item filter" {
  run ${TFMINE} ls -f ${PLANS}/long -i aws_route.nat_0
  assert_success
  assert_output "  + aws_route.nat_0"
  run ${TFMINE} ls -f ${PLANS}/long -i aws_route.nat_5
  assert_success
  assert_output ""
}

@test "list with filter flags - positive" {

  run ${TFMINE} ls -f ${PLANS}/create-and-update -c
  assert_success
  assert_output "  + aws_ebs_volume.registry-sync"

  run ${TFMINE} ls -f ${PLANS}/create-and-update -u
  assert_success
  assert_output \
"  ~ aws_ebs_volume.logging[0]
  ~ aws_ebs_volume.logging[1]"

  run ${TFMINE} ls -f ${PLANS}/create-and-recreate -r
  assert_success
  assert_output \
"-/+ aws_ebs_volume.logging[0]
-/+ aws_ebs_volume.logging[1]"

  run ${TFMINE} ls -f ${PLANS}/destroy -d
  assert_success
  assert_output \
"  - aws_ebs_volume.redis
  - aws_ebs_volume.registry
  - aws_efs_file_system.efs"
}

@test "list with filter flags - negative" {

  run ${TFMINE} ls -f ${PLANS}/destroy -c
  assert_success
  assert_output ""

  run ${TFMINE} ls -f ${PLANS}/create-and-recreate -u
  assert_success
  assert_output ""

  run ${TFMINE} ls -f ${PLANS}/create-and-update -r
  assert_success
  assert_output ""

  run ${TFMINE} ls -f ${PLANS}/create-and-update -d
  assert_success
  assert_output ""
}
