# BOSH Release for logsearch

## Usage

To use this bosh release, first upload it to your bosh:

```
bosh target BOSH_HOST
git clone https://github.com/cloudfoundry-community/logsearch-boshrelease.git
cd logsearch-boshrelease
bosh upload release releases/logsearch-X.yml # X => latest logsearch release
bosh deployment your_deployment_manifest.yml # TODO - document how to create a deployment manifest
bosh deploy
```

## Process for creating new releases

1.  Create `feature-branch` and PR to merge to `develop`.  Deploy against local bosh-lite. Collaborate
2.  Merge PR into `develop`
3.  Create & deploy dev release to test cluster (TODO: automate this step)
```
bosh target XXX # XXX is the BOSH director where your test cluster runs
rake dev_release:create_and_upload
bosh deployment YYY # YYY is your test cluster manifest
bosh deploy
```
4.  Create final release in `release-candidate`; deploy and test
5.  PR `release-candidate` -> `master` - add changelog notes
6.  merge to `master` & announce new release

## Testing

```
RESTCLIENT_LOG=stdout API_URL="http://10.244.2.2" INGESTOR_HOST="10.244.2.14" bundle exec rspec
```