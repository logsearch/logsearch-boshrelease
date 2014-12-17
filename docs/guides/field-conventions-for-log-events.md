---
title: "Field Conventions for Log Events"
---


## Field Names

When you're writing filters for logstash events, it may be helpful to rely on some field name conventions.

 0. Fields prefixed with `@` are metadata about the actual log message.
     1. `@message` is the field logsearch uses to maintain the original message. It's safe for you to remove this if you
        don't care to keep the original copy.
     1. `@timestamp` is used to represent when the log message was emitted.
     1. `@source[*]` represents metadata about where the log message came from (e.g. host, path, offset). Some ingestors
        may add this automatically, such as `ingestor_lumberjack`.
     1. `@type` is a high-level, log format name for how this message is formatted (e.g. `apache_common`).

Additionally, certain features within logsearch may add additional metadata within the `@ingestor` and `@parser` fields.


## Shippers

Log shippers typically have the most context about a log, therefore they should be responsible for including the
necessary metadata about the log messages. For example, rather than just blindly shipping off log messages from files,
consider including the file path of the log file and the hostname it's located on. Or if you're using a single logsearch
deployment for both production and development, tag messages with their respective environment.

Different protocols may have different conventions for this. For example, the lumberjack protocol automatically adds
host, path, and offset with each message. The syslog protocol doesn't have a built-in field for a log file path,
however, which means you can either inject the file path as a structured data field (per [RFC 5424][1]), or prefix each
outgoing syslog message with the path and simply parse the field back out before you let the rest of your parsers work
with the message field.


## Hashes

We've found hashes to be more convenient than fully namespaced, string keys. For example, within logstash configuration,
prefer fields such as `remote[reverse_ip]` instead of `remote.reverse_ip`. The former ensures `remote` is treated as a
hash with a `reverse_ip` key, whereas the latter is simply a longer key name in the root level. This helps with
readability of the raw log event data, but also provides a more compact representation.


 [1]: https://tools.ietf.org/html/rfc5424#section-6.3
