---
title: "Maintaining Log Parser Configurations"
---

As your logsearch deployment becomes more heavily used, you're bound to receive multiple different log formats. Trying
to manage all the different parser rules in a `parser.filters` property as a multi-line string inside a YAML-based
configuration file can become very difficult.

The easiest improvement is to extract the filter configuration into a separate file which lives alongside your
deployment manifest. Since BOSH automatically supports manifests which are ERB templates, you can do something like the
following...

    properties:
      parser:
        filters: |
                <%= File.read('logstash-filters.conf').gsub(/^/, '            ').strip %>

This means you will no longer have a large block of logstash configuration cluttering up the rest of your deployment
manifest. It also reduces the potential errors of messing up YAML multi-line string indentation and improper escaping of
multibyte characters.

By extracting the logstash configuration file, it's also easier to bind it to any existing continuous integration
workflows. For example, if you use the `logsearch/filters-common` approach of managing filters and tests, after a
successful logstash integration build you could automatically update the `logstash-filters.conf` file with the build
artifact.


## Failures in `grok`

As you start adding more log formats, your dependency on logstash's `grok` filter will also increase significantly. With
more variety you'll be more likely to encounter edge cases that your `grok` patterns aren't designed (or expected) to
catch. Typically, if a `grok` fails, it will tag the event with `_grokparsefailure` to let you know it failed. When you
have hundreds of `grok`s, this becomes difficult to debug.

Instead of the default, we've started trying to explicitly set the `tag_on_failure` value to something unique. Going
further, we've started prefixing the value with `fail/` and following it with slash-split, increasingly specific terms
to help us track down the specific rule. For example, with the following if a message fails we'll know it occurred in
our `backhaul` log type and in the section responsible for extracting `Messaging.RabbitMQ.Routing` data...

    grok {
        ...
        tag_on_failure => [ "fail/backhaul/Messaging.RabbitMQ.Routing" ]
    }

The `fail/` prefix also allows us to write very performant, prefix queries against the `tag` field and quickly aggregate
their values.
