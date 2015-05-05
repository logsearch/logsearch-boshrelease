---
title: "Deploying Logsearch with the LogSearch Workspace"
---

Logsearch behaves just like any other BOSH release - it has jobs for you to allocate and properties for you to
configure. If you need an introduction to BOSH, please review [their documentation][1] first.

The [Logsearch Workspace](https://github.com/logsearch/workspace) project provides a local Vagrant VM including all the required dependencies and an embedded instance of [BOSH Lite][4]
which enables allows you to deploy a local LogSearch development/test cluster.

The screencast and instructions below walk step by step through setting up a local Logsearch cluster running in the Logsearch Workspace.  
On a reasonably fast internet connection this takes about 30 minutes.

<iframe width="854" height="510" src="//www.youtube.com/embed/d6KrVg54FJI" frameborder="0" allowfullscreen></iframe>

The process and concepts for deploying a Logsearch cluster to a cloud IaaS are identical; the only difference being that you target and deploy to a BOSH director running on the IaaS. 

## Start a Logsearch Workspace

The instructions below walk through setting up a local Logsearch Workspace VM based on Vagrant and Virtualbox:

0. You need to have installed:
    * Git 1.8+  (check with `git version`)
    * Vagrant 1.6.5+ (check with `vagrant version`)
    * VirtualBox 4.3.18+ (check with `vboxmanage --version`)
    * A SSH client (check with `ssh -V`)
    * 6GB of FREE RAM - we've tested on machines with 16MB+

0. Installing above dependencies

    * on Windows
    
        We recommend you use the [Chocolatey](https://chocolatey.org/) package manager to install the above     dependencies on  Windows
            
        Open an _Administrative PowerShell_ prompt and:
            
            iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) # Installs olatey
            choco install git         # Installs git AND a ssh client
            choco install virtualbox  # Installs VirtualBox
            choco install vagrant     # Installs Vagrant

    * on Mac OSX

        We recommend you use the [Homebrew](http://brew.sh/) package manager to install the above dependencies on Mac
        
        Open an terminal and:
        
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" # Installs     HomeBrew
            brew install git                       #installs git
            brew install caskroom/cask/brew-cask   # homebrew-cask manages binary apps with HomeBrew
            brew cask install virtualbox           # Installs VirtualBox
            brew cask install vagrant              # Installs Vagrant

0. Launch a Vagrant VM (This downloads [a custom Vagrant box of approx 1.6GB in size from AWS S3](https://github.com/Logsearch/workspace/blob/master/Vagrantfile#L12))

    * on Windows

        _NB! You must run this from an Administrative console prompt_

            cd C:/path/to/where/you/want/logsearch-workspace
            git clone https://github.com/logsearch/workspace
            vagrant up

    * on Mac OSX

        _You will be prompted for your administrator password_

            cd /path/to/where/you/want/logsearch-workspace
            git clone https://github.com/logsearch/workspace
            vagrant up
          
0. SSH into your workspace
    * Using the default SSH client: `vagrant ssh`
    * In case you want to use a custom SSH client (eg, Putty/Kitty on Windows), you can get the SSH settings needed using `vagrant ssh-config`
    * An SSH agent must be started, when using a custom SSH client
    * Once your SSH terminal is connected you should see something like:

             /path/to/where/you/want/logsearch-workspace $ vagrant ssh
             Welcome to Ubuntu 14.04 LTS (GNU/Linux 3.13.0-37-generic x86_64)
             
              * Documentation:  https://help.ubuntu.com/
             +-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+
             |L|o|g|S|e|a|r|c|h| |W|o|r|k|s|p|a|c|e|
             +-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+
             
             ...snip...

             Loading ENV variables from ~/.env
             Port Mappings:
                 192.168.50.4:10080 -> 10.244.10.2:80
                 192.168.50.4:10443 -> 10.244.10.6:443
             [logsearch workspace] ~ ▸ 

    _NB:  You can ignore warnings about missing AWS & GIT credentials in this tutorial, since we won't be interacting with AWS or Git_

## Target the workspace's local test environments BOSH

By convention, configuration for your Logsearch cluster deployments is stored in the workspace under `~/environments/$ORGANISATION/$ENVIRONMENT`.

Navigating to the relevant $ENVIRONMENT folder targets that environment's BOSH director.

So, to target the local test environment, simply:

    cd ~/environments/local/test

Running `bosh status` from that folder will show that you have targeted the correct BOSH director:

    [logsearch workspace] ~/environments/local/test ▸ bosh status
    Config
                 /home/vagrant/environments/local/test/.bosh_config
    
    Director
      Name       Bosh Lite Director
      URL        https://127.0.0.1:25555
      Version    1.2749.0 (00000000)
      User       admin
      UUID       cf8dc1fc-9c42-4ffc-96f1-fbad983a6ce6
      CPI        vsphere
      dns        disabled
      compiled_package_cache enabled (provider: local)
      snapshots  enabled 
    
    Deployment
      not set

A BOSH deployment is comprised of 3 pieces:

0.  A stemcell (a base Ubuntu VM image running the BOSH agent).  You can check which stemcells have been uploaded to your BOSH director has using `bosh stemcells`.  You should see something like:

        [logsearch workspace] ~/environments/local/test ▸ bosh stemcells
        
        +---------------------------------------------+---------+--------------------------------------+
        | Name                                        | Version | CID                                  |
        +---------------------------------------------+---------+--------------------------------------+
        | bosh-warden-boshlite-ubuntu-trusty-go_agent | 389     | d3d51856-880f-4d96-6dad-c412e37b004e |
        +---------------------------------------------+---------+--------------------------------------+
        
        (*) Currently in-use
        
        Stemcells total: 1


0.  A release (the software packages that need to be installed on machines in the cluster).  You can check which releases have been uploaded to your BOSH director using `bosh releases`.  You should see something like:
        
        [logsearch workspace] ~/environments/local/test ▸ bosh releases
        
        +-----------+----------+-------------+
        | Name      | Versions | Commit Hash |
        +-----------+----------+-------------+
        | logsearch | 17       | 9d9993c3+   |
        +-----------+----------+-------------+
        (+) Uncommitted changes
        
        Releases total: 1

0.  A deployment manifest (A YAML config file specifying what VMs should be created, what should be installed on them, and how these should be configured).  By convention these are stored in `~/environments/$ORGANISATION/$ENVIRONMENT/$DEPLOYMENT/manifest.yml`.  Use `cat ~/environments/local/test/logsearch/manifest.yml` to view the contents of the local test Logsearch cluster we will be deploying.  Eg:

        [logsearch workspace] ~/environments/local/test ▸ cat ~/environments/local/test/logsearch/manifest.yml        
        ---
        name: <%= deployment_name %>
        director_uuid: <%= director_uuid %> 
        
        releases:
        - name: logsearch
          version: latest
        
        compilation:
        ...snip...

## Deploy

The deployment manifest at `~/environments/local/test/logsearch/manifest.yml` defines a deployment with the following configuration

 * api (`10.244.2.2`) - where you will execute queries and load kibana via HTTP on port 80
 * ingestor (`10.244.2.14`) - with a Syslog over TLS exposed on port 443
 * queue
 * log_parser
 * 2 &times; elasticsearch data nodes

To deploy this cluster run:

    [logsearch workspace] ~/environments/local/test ▸ bosh -n -d logsearch/manifest.yml deploy

you should see:

    Processing deployment manifest
    ------------------------------
    Getting deployment properties from director...
    Compiling deployment manifest...
        
    Deploying
    ---------
    Deployment name: `manifest.yml'
    Director name: `Bosh Lite Director'
        
    Director task 3
      Started preparing deployment
      Started preparing deployment > Binding deployment. Done (00:00:00)
      Started preparing deployment > Binding releases. Done (00:00:00)
      Started preparing deployment > Binding existing deployment. Done (00:00:00)
      Started preparing deployment > Binding resource pools. Done (00:00:00)
      Started preparing deployment > Binding stemcells. Done (00:00:00)
      Started preparing deployment > Binding templates. Done (00:00:00)
      Started preparing deployment > Binding properties. Done (00:00:00)
      Started preparing deployment > Binding unallocated VMs. Done (00:00:00)
      Started preparing deployment > Binding instance networks. Done (00:00:00)
         Done preparing deployment (00:00:00)
               Started preparing package compilation > Finding packages to compile. Done (00:00:00)
               Started compiling packages
      Started compiling packages > redis/cd861700c83a544b6d0bba3b620017d22cf0d726
      Started compiling packages > logstash/5e1a6fd74024db3c4923397f71da1c71a0cb51d3
         Done compiling packages > redis/cd861700c83a544b6d0bba3b620017d22cf0d726 (00:00:21)
      Started compiling packages > python/356d0ec8645d158e9d1a517c2fd071762d43429d
         Done compiling packages > logstash/5e1a6fd74024db3c4923397f71da1c71a0cb51d3 (00:00:22)
      Started compiling packages > nginx/07fa264094f0ebb55bcc9990578d9cc159748dc0. Done (00:00:42)
      Started compiling packages > java7/c04c102fd6c411f867dc44ee65279dd47eb5c8a0. Done (00:00:12)
      Started compiling packages > elasticsearch/e866cba047ff7ce1f31e3bcfce0762e13c2f47cf. Done (00:00:05)
         Done compiling packages > python/356d0ec8645d158e9d1a517c2fd071762d43429d (00:01:40)
      Started compiling packages > collectd/426c5cb42ff5a326e539aef22f7d14526a02c1be. Done (00:00:48)
         Done compiling packages (00:02:49)
                 
      Started preparing dns > Binding DNS. Done (00:00:00)
        
      Started creating bound missing vms
      Started creating bound missing vms > warden/0
      Started creating bound missing vms > warden/1
      Started creating bound missing vms > warden/2
      Started creating bound missing vms > warden/3
      Started creating bound missing vms > warden/4
      Started creating bound missing vms > warden/5
         Done creating bound missing vms > warden/3 (00:00:02)
         Done creating bound missing vms > warden/1 (00:00:02)
         Done creating bound missing vms > warden/2 (00:00:02)
         Done creating bound missing vms > warden/4 (00:00:03)
         Done creating bound missing vms > warden/5 (00:00:04)
         Done creating bound missing vms > warden/0 (00:00:04)
         Done creating bound missing vms (00:00:04)
        
      Started binding instance vms
      Started binding instance vms > api/0
      Started binding instance vms > ingestor/0
      Started binding instance vms > queue/0
      Started binding instance vms > log_parser/0
      Started binding instance vms > elasticsearch_az1/0
      Started binding instance vms > elasticsearch_az2/0
         Done binding instance vms > ingestor/0 (00:00:00)
         Done binding instance vms > api/0 (00:00:00)
         Done binding instance vms > queue/0 (00:00:00)
         Done binding instance vms > elasticsearch_az1/0 (00:00:00)
         Done binding instance vms > elasticsearch_az2/0 (00:00:00)
         Done binding instance vms > log_parser/0 (00:00:00)
         Done binding instance vms (00:00:00)
        
      Started preparing configuration > Binding configuration. Done (00:00:01)
        
      Started updating job api > api/0 (canary). Done (00:00:43)
      Started updating job ingestor > ingestor/0 (canary). Done (00:00:47)
      Started updating job queue > queue/0 (canary). Done (00:00:38)
      Started updating job log_parser > log_parser/0 (canary). Done (00:00:49)
      Started updating job elasticsearch_az1 > elasticsearch_az1/0 (canary). Done (00:00:44)
      Started updating job elasticsearch_az2 > elasticsearch_az2/0 (canary). Done (00:00:44)
        
    Task 3 done
        
    Started   2014-12-11 15:55:39 UTC
    Finished  2014-12-11 16:00:09 UTC
    Duration  00:04:30
        
    Deployed `manifest.yml' to `Bosh Lite Director'

## Verify

  * Run `bosh vms` to see the IPs assigned to each VM in the deployment:

        [logsearch workspace] ~/environments/local/test ▸ bosh vms

        Deployment `vagrant-logsearch'
        
        Director task 27
        
        Task 27 done
        
        +---------------------+---------+---------------+---------------+
        | Job/index           | State   | Resource Pool | IPs           |
        +---------------------+---------+---------------+---------------+
        | api/0               | running | warden        | 10.244.10.2   |
        | elasticsearch_az1/0 | running | warden        | 10.244.10.122 |
        | elasticsearch_az2/0 | running | warden        | 10.244.10.126 |
        | ingestor/0          | running | warden        | 10.244.10.6   |
        | log_parser/0        | running | warden        | 10.244.10.118 |
        | queue/0             | running | warden        | 10.244.10.10  |
        +---------------------+---------+---------------+---------------+
       
        VMs total: 6
  
  * From inside the Workspace you can access these IPs directly, eg: query the api/0 node using `curl 10.244.10.2`

        [logsearch workspace] ~/environments/local/test ▸ curl 10.244.10.2

          {
            "status" : 200,
            "name" : "api/0",
            "version" : {
              "number" : "1.2.1",
              "build_hash" : "6c95b759f9e7ef0f8e17f77d850da43ce8a4b364",
              "build_timestamp" : "2014-06-03T15:02:52Z",
              "build_snapshot" : false,
              "lucene_version" : "4.8"
            },
            "tagline" : "You Know, for Search"
           }

  * Port mappings have been set up between the Workspace's external IP and these internal IPs.  You can see what these are using `cat ~/port_mappings.txt` : 

        [logsearch workspace] ~/environments/local/test ▸ cat ~/port_mappings.txt
  
          Port Mappings:
            192.168.50.4:10080 -> 10.244.10.2:80
            192.168.50.4:10443 -> 10.244.10.6:443
   
    Thus, from outside the Workspace (eg, in your browser), the same curl request can be made using `http://192.168.50.4:10080`

## Troubleshooting

### BOSH HTTP 500 or 502 errors 

One of the BOSH services has failed to start up.  Grepping the BOSH logs can give a clue as to what is wrong, often something like Redis has failed to start.  Try

```
sudo -i
grep -r 'ERROR' /var/vcap/sys/log/director/*.log
```

If you see something like this:
```
[logsearch workspace] ~ ▸ grep -r 'ERROR' /var/vcap/sys/log/director/*.log
/var/vcap/sys/log/director/director.debug.log:E, [2015-01-27T14:28:02.103117 #2540] [0x3f9c4bdcd328] ERROR -- : Redis::CannotConnectError - Error connecting to Redis on 127.0.0.1:25255 (ECONNREFUSED):
```
you can try restart redis by running

```
monit restart redis
```

You can list all of BOSH's services by running `monit summary`, and restart any of the others mentioned in the logs using `monit restart <servicename>`

### Recovering after rebooting the logsearch-workspace

A limitation of the logsearch workspace is that it will "loose" your deployments when the VM gets rebooting.  Fortunately, it is straight forward to recover them; as is [described here](http://www.logsearch.io/docs/workspace/recovering-after-a-reboot.html).

__WARNING__:  The resurrection process won't retain any data you ship into your DEV logsearch cluster.


---

**Next Topic**:  
[Shipping Some Logs](./shipping-some-logs.md)


 [1]: http://docs.cloudfoundry.org/bosh/
 [2]: https://github.com/logsearch/logsearch-boshrelease/releases
 [3]: https://github.com/logsearch/logsearch-boshrelease/blob/develop/examples/bosh-lite.yml
 [4]: https://github.com/cloudfoundry/bosh-lite
