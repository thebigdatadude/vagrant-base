# Vagrant Base Environment

This project contains basic Vagrant machines that allow you to roll out test environments with Vagrant. The default setup will include an Apache Ambari Server, a master and several worker nodes that can then be used to be provisioned through Apache Ambari. Right now the base machines will have Hortonworks HDP 2.2 repositories configured such that any Hortonworks HDP can be provisioned.

The aim of this project is to make all the scripts as provider agnostic as possible such that you can also run this against your OpenStack installation or your public cloud accounts with Amazon AWS, and Microsoft Azure.
