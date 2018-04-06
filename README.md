[![Build Status](https://travis-ci.org/xelalexv/tfminer.svg?branch=master)](https://travis-ci.org/xelalexv/tfminer)

# *tfminer*

*tfminer* is a simple parser for extracting information from **console output** generated when running *Terraform*'s plan command, **not** the plan saved by *Terraform*. It was originally created to help testing *Terraform* templates. *Terraform* currently only allows to save plans in binary format, which has no stable specification and does not lend itself to easy information extraction. Implementing *tfminer* as a plain shell script was a deliberate design choice, to avoid pulling in additional dependencies into the tested projects.

## Usage
Simply get the `tfmine` shell script and run with `--help` for instructions.

## Features

- list items contained in a plan
```
./tfmine ls -f test/plans/create-and-update
  ~ aws_ebs_volume.logging[0]
  ~ aws_ebs_volume.logging[1]
  + aws_ebs_volume.registry-sync
```

- show an item with all its properties
```
./tfmine get -f test/plans/create-and-update -i aws_ebs_volume.registry-sync
  + aws_ebs_volume.registry-sync
      id:                <computed>
      arn:               <computed>
      availability_zone: "eu-central-1a"
      encrypted:         "true"
      iops:              <computed>
      kms_key_id:        <computed>
      size:              "50"
      snapshot_id:       <computed>
      tags.%:            "2"
      tags.Name:         "registry-sync"
      tags.realm:        "e2e-hm-a"
      type:              "gp2"
```

- get a particular property from an item
```
./tfmine get -f test/plans/create-and-update -i aws_ebs_volume.registry-sync -p availability_zone
eu-central-1a
```

- get list properties
```
./tfmine get -f test/plans/create-and-update -i aws_ebs_volume.registry-sync -p tags
Name="registry-sync"
realm="e2e-hm-a"
```

- basic filtering for all of the above
```
./tfmine ls -f test/plans/create-and-update --created
  + aws_ebs_volume.registry-sync
```
