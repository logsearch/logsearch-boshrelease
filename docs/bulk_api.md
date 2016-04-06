# Elasticsearch Bulk API

This release contains an errand that enables configuration of elasticsearch
via its Bulk API. Features of this API are documented [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html).

To use your own bulk requests with this release, take the following steps:
  * replace the contents of `src/bulk_request/bulk_request` with the requests you would like to make. There are some examples provided
  * `bosh deploy`
  * `bosh run errand bulk_request`


