If you'll be uploading stuff, be sure to put your credentials in `config/private-main.yml`. Override buckets for testing.

You might want to update your experimental concourse pipeline...

    $ fly configure \
      --config pipelines/concourse.yml \
      --vars-from config/default.yml \
      --vars-from config/private-main.yml \
      logsearch-boshrelease

You might want to serve your local repository while tweaking scripts...

    $ git daemon --base-path=../ -v --listen=172.23.240.4 --port=9191 --export-all
    $ echo 'git-master-uri: "git://172.23.240.4:9191/"' >> config/private-main.yml
