---
title: "Creating a New Release"
---

We regularly need to create new BOSH releases, and this is the process we go through...


## Creating a Release

0. Figure out which release you'll be creating next...

        git tag -l | sort -tv -k2 -n
        RELEASE_NUM=12

0. Ensure you're on the latest `develop` branch...

        git checkout develop
        git pull --ff-only origin develop

0. Ensure you've deployed everything and it's all working...

        rake dev_release:create_and_upload_and_deploy

0. If you have new blobs, upload them and commit those metadata changes...

        bosh upload blobs
        git commit -m 'upload new blobs for release'

0. Create a final release...

        bosh create release --final --with-tarball
        git add -A .final_builds releases/index.yml
        ( cd releases && ln -fs logsearch-$RELEASE_NUM.yml logsearch-latest.yml )
        git add releases/logsearch-$RELEASE_NUM.yml releases/logsearch-latest.yml

0. Upload the tarball artifacts...

        aws s3api put-object --bucket logsearch-boshrelease --key "releases/logsearch-${RELEASE_NUM}.tgz" --body "releases/logsearch-${RELEASE_NUM}.tgz"
        aws s3api copy-object --bucket logsearch-boshrelease --key "releases/logsearch-latest.tgz" --copy-source "logsearch-boshrelease/releases/logsearch-${RELEASE_NUM}.tgz"

0. Review the logs to create a draft summarizing the release (see Release Notes section)...

        git log v$(($RELEASE_NUM-1))..HEAD
        vim release.md

0. Commit, tag, and create GitHub release...

        ( echo "Release $RELEASE_NUM" ; echo "" ; cat release.md ) | git commit -F-
        git tag v$RELEASE_NUM
        git push origin develop v$RELEASE_NUM
        ( echo -n "{\"tag_name\":\"v$RELEASE_NUM\",\"body\":\"" ; sed -e 's/"/\\"/g' -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' release.md ; echo "\"}" ) | curl -H "Authorization: token $GITHUB_TOKEN" -d @- https://api.github.com/repos/logsearch/logsearch-boshrelease/releases

0. Cleanup and get back to developing...

        rm release.md


## Writing Release Notes

You should always include a summary of the release in your commits. There should be three parts:

0. A short, one or two sentence summary of the release which could be relayed to a non-technical manager. If there's a theme to all the included changes, mention it.
0. If there are any backward incompatibilities, include migration steps for each breaking change.
0. A list of changes which affect how the software is used or managed. This should roughly correlate to the commits. Reference issue numbers whenever they're available. Keep items limited to "what is" and not "why"  (leave the "why" discussions in the original commit messages or relevant issues).

Here is an example:

 > This simplifies the elasticsearch configuration making it easier to identify where the nodes are running within the bosh
 > cluster. This also includes a fix for Kibana 3.1.0.
 > 
 >  * FIX: proxy configuration to allow GET to field mapping data (#41)
 >  * FIX: elasticsearch warning about unregistered file appender (#43)
 >  * ADD: new elasticsearch attributes (job_name, job_index) based on bosh job/index (#38)
 >  * ADD: static elasticsearch node names based on bosh job/index
 >  * REMOVE: elasticsearch cloud-aws plugin (#42)
