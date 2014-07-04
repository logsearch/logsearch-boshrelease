If you're needing to tweak and improve elasticsearch memory usage, you might
want to enable GC logging. We've found the following set to be verbose and
helpful...

    elasticsearch.exec.options:
    - "-XX:+PrintCommandLineFlags"
    - "-XX:+PrintFlagsFinal"
    - "-XX:+PrintPromotionFailure"
    - "-XX:+PrintReferenceGC"
    - "-XX:+PrintGCDateStamps"
    - "-XX:+PrintGCDetails"
