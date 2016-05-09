# Logsearch

A scalable stack of [Elasticsearch](http://www.elasticsearch.org/overview/elasticsearch/),
[Logstash](http://www.elasticsearch.org/overview/logstash/), and
[Kibana](http://www.elasticsearch.org/overview/kibana/) for your
own [BOSH](http://docs.cloudfoundry.org/bosh/)-managed infrastructure.

## BREAKING CHANGES

Logsearch < v23.0.0 was based on Elasticsearch 1.x and Kibana 3.

Logsearch > v200 is based on Elasticsearch 2.x and Kibana 4.

There is NO upgrade path.  Sorry :(

## Getting Started

This repo contains Logsearch Core; which deploys an ELK cluster that can recieve and parse logs via syslog
that contain JSON.

Most users will want to combine Logsearch Core with a Logsearch Addon to customise their cluster for a
particular type of logs.  Its likely you want to be following an Addon installation guides - see below
for a list of the common Addons:

  * [Logsearch for CloudFoundry](https://github.com/logsearch/logsearch-for-cloudfoundry)

If you are sure you want install just Logsearch Core, read on...

## Installing Logsearch Core

0. Upload the latest logsearch release from [bosh.io](https://bosh.io)...

        $ bosh upload release https://bosh.io/d/github.com/logsearch/logsearch-boshrelease

0. Customise your deployment stub:

   * Make a copy of `templates/stub.$INFRASTRUCTURE.example.yml` to `logsearch-stub.yml`
   * Edit to match your IAAS settings

0. Generate a manifest

        $ scripts/generate_deployment_manifest $INFRASTRUCTURE logsearch-stub.yml > logsearch.yml

0. Deploy!

    $ bosh -d logsearch.yml deploy

## Common customisations:

0. Adding new parsing rules:

        logstash_parser:
          filters: |
             # Put your additional Logstash filter config here, eg:
             json {
                source => "@message"
                remove_field => ["@message"]
             }


### Release Channels

 * The latest stable, final release is available on [bosh.io](http://bosh.io/releases/github.com/logsearch/logsearch-boshrelease)
 * **develop** - The develop branch in this repo is deployed to our test environments.  It is occasionally broken - use with care!

## Known issues

#### VMs lose connectivity to each other after VM recreation (eg. instance type upgrade)

While this issue is not specific to this boshrelease, it is worth noting.

On certain IAAS'es, (AWS confirmed), the bosh-agent fails to flush the ARP cache of the VMs in the deployment which, in rare cases, results in VMs not being able to communicate with each other after some of them has been recreated. The symptoms of when this happens are varied depending on the affected VMs. It could be anything from HAproxy reporting it couldn't find any backends (eg. Kibana) or the parsers failing to connect to the queue.

A [pull request](https://github.com/cloudfoundry/bosh/pull/1190) has been merged into BOSH develop so an official fix for this issue is coming.

The issue, if occurs, should fix itself as the kernel updates incomplete ARP entries, which **should** happen within minutes

This can also be done manually if an immediate manual fix is preferred. This should be done on the VMs that are trying to talk to the VM that has been recreated.

```
arp -d $recreated_vm_ip
```

## License

[Apache License 2.0](./LICENSE)
