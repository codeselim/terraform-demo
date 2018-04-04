# Terraform-demo


Every step in this tutorial is presented with a tagged commit. To switch between steps use:

`$ git checkout tags/<tag_name>` (e.g. git checkout tags/step-2)

## step-3

Separated environments with S3 bucket as backend. Every environment has his own state store in an S3 Bucket. 

At this stage, infrastructure components are separated into reusable modules

## step-2

Refactored code, input variables separated.

Usage of helper functions : element, lookup, count ...etc

## step-1

All the infrastructure is define in one terraform file `infrastructure.tf`.

At this stage, no storage backend is used to maintain the terraform state. 
