#!/usr/bin/env ./libs/bats/bin/bats

load './libs/bats-support/load'
load './libs/bats-assert/load'
load './helper'

@test "get prop from file" {
    run ${TFMINE} get -f ${PLANS}/long \
        -i aws_route.internet -p destination_cidr_block
    assert_success
    assert_output "0.0.0.0/0"
}

@test "get prop from stdin" {
    run ${TFMINE} get \
        -i aws_efs_mount_target.efs -p file_system_id < ${PLANS}/long
    assert_success
    assert_output "fs-1fbb4a46"
}

@test "get prop - item not found" {
    run ${TFMINE} get -f ${PLANS}/long -i flying_circus -p id
    assert_failure
    assert_output ""
}

@test "get prop - prop not found" {
    run ${TFMINE} get -f ${PLANS}/long \
        -i aws_efs_mount_target.efs -p flying_circus
    assert_failure
    assert_output ""
}

@test "get changed prop" {

    run ${TFMINE} get -f ${PLANS}/create-and-update \
        -i aws_ebs_volume.logging[1] -p tags.realm
    assert_success
    assert_output '"e2e-hm-a" => "e2e-hm-a-a"'

    run ${TFMINE} get -f ${PLANS}/create-and-update \
        -i aws_ebs_volume.logging[1] -p tags.realm -o
    assert_success
    assert_output 'e2e-hm-a'

    run ${TFMINE} get -f ${PLANS}/create-and-update \
        -i aws_ebs_volume.logging[1] -p tags.realm -n
    assert_success
    assert_output 'e2e-hm-a-a'
}

@test "get prop with specials" {

    run ${TFMINE} get -f ${PLANS}/create-and-recreate \
        -i aws_ebs_volume.logging[1] -p id -o
    assert_success
    assert_output 'vol-0fc45113\"613673152'

    run ${TFMINE} get -f ${PLANS}/create-and-recreate \
        -i aws_ebs_volume.logging[1] -p id -n
    assert_success
    assert_output "<computed>"

    run ${TFMINE} get -f ${PLANS}/create-and-recreate \
        -i aws_ebs_volume.logging[1] -p tags.Name -o
    assert_success
    assert_output "logg=>ing-1"

    run ${TFMINE} get -f ${PLANS}/create-and-recreate \
        -i aws_ebs_volume.logging[1] -p tags.Name -n
    assert_success
    assert_output "logg=>ing-2"
}
