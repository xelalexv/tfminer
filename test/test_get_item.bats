#!/usr/bin/env ./libs/bats/bin/bats

load './libs/bats-support/load'
load './libs/bats-assert/load'
load './helper'

@test "get item from file" {
    run ${TFMINE} get -f ${PLANS}/long -i aws_route.internet
    assert_success
    assert_output \
'  + aws_route.internet
      id:                                        <computed>
      destination_cidr_block:                    "0.0.0.0/0"
      destination_prefix_list_id:                <computed>
      egress_only_gateway_id:                    <computed>
      gateway_id:                                "${aws_internet_gateway.igw.id}"
      instance_id:                               <computed>
      instance_owner_id:                         <computed>
      nat_gateway_id:                            <computed>
      network_interface_id:                      <computed>
      origin:                                    <computed>
      route_table_id:                            "${aws_route_table.internet.id}"
      state:                                     <computed>'
}

@test "get item from stdin" {
    run ${TFMINE} get -i aws_efs_mount_target.efs < ${PLANS}/long
    assert_success
    assert_output \
'  + aws_efs_mount_target.efs
      id:                                        <computed>
      dns_name:                                  <computed>
      file_system_id:                            "fs-1fbb4a46"
      ip_address:                                <computed>
      network_interface_id:                      <computed>
      security_groups.#:                         <computed>
      subnet_id:                                 "${aws_subnet.private-0.id}"'
}

@test "item not found" {
    run ${TFMINE} get -f ${PLANS}/long -i flying_circus
    assert_failure
    assert_output ""
}

@test "get item with filter flags - positive" {

    run ${TFMINE} get -f ${PLANS}/create-and-update \
        -i aws_ebs_volume.registry-sync -c
    assert_success
    assert_line "  + aws_ebs_volume.registry-sync"

    run ${TFMINE} get -f ${PLANS}/create-and-update \
        -i aws_ebs_volume.logging[0] -u
    assert_success
    assert_line "  ~ aws_ebs_volume.logging[0]"

    run ${TFMINE} get -f ${PLANS}/create-and-recreate \
        -i aws_ebs_volume.logging[1] -r
    assert_success
    assert_line "-/+ aws_ebs_volume.logging[1] (new resource required)"

    run ${TFMINE} get -f ${PLANS}/destroy -i aws_ebs_volume.redis -d
    assert_success
    assert_line "  - aws_ebs_volume.redis"
}

@test "get item with filter flags - negative" {

    run ${TFMINE} get -f ${PLANS}/destroy -i aws_ebs_volume.redis -c
    assert_failure

    run ${TFMINE} get -f ${PLANS}/create-and-recreate \
        -i aws_ebs_volume.registry-sync -u
    assert_failure

    run ${TFMINE} get -f ${PLANS}/create-and-update \
        -i aws_ebs_volume.registry-sync -r
    assert_failure

    run ${TFMINE} get -f ${PLANS}/create-and-update \
        -i aws_ebs_volume.logging[1] -d
    assert_failure
}
