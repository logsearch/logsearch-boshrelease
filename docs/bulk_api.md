# Elasticsearch Bulk API

The bulk api allows multiple actions to be sent to ES in 1 request. The full documentation is located [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html) on the offical ES site.

To use your own bulk requests with this release, take the following steps:

  * Fork the [logsearch-addons](https://github.com/logsearch/example-logsearch-addon-boshrelease) bosh release
  * Modify the request file in `logsearch-addons/src/create_bulk_request/request`
  * Colocate the create_bulk_request job template from the logsearch-addons onto the logsearch-boshrelease maintenance vm
  * Include the logsearch-addons under the releases section of your manifest
  * Include the path to the bulk request files under elasticsearch_config.bulk_data_files (this supports multiple files, which are configurable in the [logsearch-addons](https://github.com/logsearch/example-logsearch-addon-boshrelease) bosh release)
  * Upload the addons release and deploy.

Your manifest should look something like:

```yaml
...

releases:
- name: logsearch
  version: latest
- name: logsearch-addons
  version: latest

...

- instances: 1
  name: maintenance
  networks:
  - name: default
  resource_pool: maintenance
  templates:
  - name: create_bulk_request
    release: logsearch-addons
  - name: elasticsearch_config
    release: logsearch
  - name: curator
    release: logsearch
	properties:
    elasticsearch_config:
      bulk_data_files: [/var/vcap/packages/create_bulk_request/request]

```
