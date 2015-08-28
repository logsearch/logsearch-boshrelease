# CI (via Concourse)

Continuous Integration is nice when it all works out...


## Pipelines

Unconventionally, we've divided up several pipeline components to make them easier to reuse. Here are the main pipeline pieces...

0. `dev` - this pipeline helps validate the quality of particular branches. It will monitor a particular branch for changes and, upon change, will run through all the appropriate tests. If they pass, the version file will be updated.
0. `release` - this pipeline helps create final releases. Manually trigger the major, minor, or patch job to kick off creating the final release which will be committed, tagged, uploaded, and pushed.
0. `pr` - this pipeline locally merges pull requests for testing and includes the `dev` pipeline to run the tests.

To combine them, the `generate` script in their respective directories will dump the resulting pipeline to STDOUT.


## Variables

Configuration files with the variables `fly` wants are located in `ci/config/*.yml`. When customizing or adding secrets use a separate file with the convention of `ci/config/*-private.yml` (they have a higher precedence and will not be committed).


## Configuration

To re-apply all the pipelines, use the `fly-configure` script...

    $ FLY_TARGET=cilabs-meta ./ci/bin/fly-configure


## Pull Requests

If you want to start testing a particularl pull request, append the pull number to the list of approved pulls...

    $ echo 180 >> ci/config/pr.txt

After running `fly-configure` to install the new PR pipeline, you'll want to unpause the pipeline to get it started. Going forward, it will automatically run when new commits are pushed for the PR. It does not currently update commit statuses within GitHub.


## Bootstrap

If you're setting up pipelines from scratch or for your own fork, you might need to initialize a few files...

    echo -n "22.0.0-dev.4" > version
    aws s3api put-object --bucket=logsearch-boshrelease --key=develop/version --body=version
    aws s3api put-object --bucket=logsearch-boshrelease --key=develop/version-wip --body=version
    
    echo -n "23.0.0" > version
    aws s3api put-object --bucket=logsearch-boshrelease --key=final/version --body=version
    aws s3api put-object --bucket=logsearch-boshrelease --key=final/version-wip --body=version

    rm version
