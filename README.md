[![Build Status](https://travis-ci.org/xelalexv/tfminer.svg?branch=master)](https://travis-ci.org/xelalexv/tfminer)

# *tfminer*

## TL;DR
*tfminer* lets you extract information out of *Terraform* console output to help you in testing your *Terraform* templates.

## Outline
*tfminer* is a simple parser for extracting information from *Terraform* **console output**, in particular for output generated when running the `plan` command. It does **not** use the plans saved by *Terraform*. *tfminer* was created to help testing *Terraform* templates. *Terraform* currently only allows to save plans in binary format, which has no stable specification and does not lend itself to easy information extraction. Implementing *tfminer* as a plain shell script was a deliberate design choice, to avoid pulling in additional dependencies into the tested projects.

## Usage
Simply get the `tfmine` shell script and run with `--help` for instructions.

## Features

Here are a few things you can do with *tfminer*:

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

- and more...

## Tests

The tests are based on [bats](https://github.com/sstephenson/bats) (BASH automated testing system). The *bats* framework + additions, are included as *Git* submodules, so after cloning this repo, make sure you get these submodules:

```bash
cd tfminer
git submodule update --init
```

The tests also serve as examples for how you might use *tfminer* for testing your *Terraform* templates. Of course, using *bats* is not a prerequisite. You can use whatever testing framework suits you best. The general idea is to run *Terraform* with the template you want to test, capture the console output, and then run your assertions on data extracted from this output with *tfminer*.
