If you're needing to tweak and improve elasticsearch memory usage, you might
want to enable GC logging. We've found the following set to be verbose and
helpful...

    elasticsearch.exec.options:
    - "-XX:+AggressiveOpts"
    - "-XX:+UseCompressedOops"
    - "-XX:+UseParNewGC"
    - "-XX:+UseConcMarkSweepGC"
    - "-XX:+CMSParallelRemarkEnabled"
    - "-XX:+PrintCommandLineFlags"
    - "-XX:+PrintFlagsFinal"
    - "-XX:+PrintPromotionFailure"
    - "-XX:+PrintReferenceGC"
    - "-XX:+PrintGCDateStamps"
    - "-XX:+PrintGCDetails"
