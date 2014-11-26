sparkles-doc-testing
====================

The goal of this repo is to test/review the SparkleFormation docs by creating a scratch implementation that follows them.

This example will include the deployment of two Autoscaling groups (one webserver ASG and a db ASG) which can talk to each other, with the webserver ASG behind an Elastic Load Balancer. 

* The ELB ports will be able to be defined at deploy time.
* The ELB will be in its own stack, so the ASG behind it can be swapped out. (so no need to adjust DNS)
