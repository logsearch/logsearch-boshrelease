---
title: "Deploying Logsearch on BOSH Lite"
---

Logsearch behaves just like any other BOSH release - it has jobs for you to allocate and properties for you to
configure. If you need an introduction to BOSH, please review [their documentation][1] first.

For simplicity, this Getting Started guide will continue with the assumption that you have a local BOSH Lite running. If
you need help getting one setup, please review [their documentation][4] first.


## Upload Release

First, you'll need to upload the latest release to the director. You can find our releases documented and artifacts
linked from the [release][2] page of our repository. Alternatively, you can simply upload the latest release...

    $ bosh upload release https://s3.amazonaws.com/logsearch-boshrelease/releases/logsearch-latest.tgz


## Deploy

You can find the sample manifest located in the repository's [`/examples/bosh-lite.yml`][3] file. The manifest has the
following configuration:

 * api (`10.244.2.2`) - where you will execute queries and load kibana
 * ingestor (`10.244.2.14`) - with lumberjack, syslog, and relp enabled
 * queue
 * log_parser
 * 2 &times; elasticsearch data nodes

Now use the manifest to create the deployment...

    $ bosh -d bosh-lite.yml deploy


## Verify

Once the deploy has finished compiling packages and starting its VMs, you should be able to query the `api/0` node and
get a `status` of `200`...

    $ curl -s api.cityindex.logsearch.io
    {
      "status" : 200,
      "name" : "api/0",
      "cluster_name" : "live-logsearch",
      "version" : {
        "number" : "1.4.0",
        "build_hash" : "bc94bd81298f81c656893ab1ddddd30a99356066",
        "build_timestamp" : "2014-11-05T14:26:12Z",
        "build_snapshot" : false,
        "lucene_version" : "4.10.2"
      },
      "tagline" : "You Know, for Search"
    }


---

**Next Topic**:  
[Shipping Some Logs](./shipping-some-logs.md)


 [1]: http://docs.cloudfoundry.org/bosh/
 [2]: https://github.com/logsearch/logsearch-boshrelease/releases
 [3]: https://github.com/logsearch/logsearch-boshrelease/blob/develop/examples/bosh-lite.yml
 [4]: https://github.com/cloudfoundry/bosh-lite
