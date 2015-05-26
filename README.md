# Vagrant Base Environment

This project contains basic [Vagrant](https://www.vagrantup.com) machines that allow you to roll out test environments with Vagrant. The default setup will include an [Apache Ambari](https://ambari.apache.org) Server, a master and several worker nodes that can then be used to be provisioned through Apache Ambari. Right now the base machines will have [Hortonworks HDP 2.2](http://hortonworks.com) repositories configured such that any Hortonworks HDP can be provisioned.

The aim of this project is to make all the scripts as provider agnostic as possible such that you can also run this against your [OpenStack](https://www.openstack.org) installation or your public cloud accounts with [Amazon AWS](http://aws.amazon.com), and [Microsoft Azure](http://azure.microsoft.com/).

## Warning / Disclaimer

Under no circumstances use this setup in production environments! To run the setup a bit more secure use the script found in bin/key-gen.ssh to generate a new SSH keypair for your local setup!
