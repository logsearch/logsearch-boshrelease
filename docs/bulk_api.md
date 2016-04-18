# Elasticsearch Bulk API

The bulk api allows multiple actions to be sent to ES in 1 request. The full documentation is located [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html) on the offical ES site.

To use your own bulk requests with this release, take the following steps:

  * Fork the [logsearch-addons](https://github.com/logsearch/example-logsearch-addon-boshrelease) bosh release
  * Modify the request file in `logsearch-addons/src/bulk_request/request`
  * N.B. You can add as many bulk request files as you like in the
  * `logsearch-addons/src/bulk-request` directory
  * Colocate the bulk_request job template from the logsearch-addons as an errand into the logsearch-boshrelease
  * Include the logsearch-addons under the releases section of your manifest
  * Upload the addons release and deploy.
  * Run the errand `bosh run errand bulk_request`

Your manifest should look something like:

```yaml
...

releases:
- name: logsearch
  version: latest
- name: logsearch-addons
  version: latest

...

jobs:
- instances: 1
  lifecycle: errand
  name: bulk_request
  networks:
  - name: default
  resource_pool: errand
  templates:
  - name: bulk_request
    release: logsearch-addons
  properties:
    bulk_request:
      elasticsearch:
	host: <your_elasticsearch_master_ip>
  resource_pool: errand
  templates:
  - name: bulk_request
  release: logsearch-addons
```
