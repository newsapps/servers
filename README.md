# Trib Apps server builder

Here we have a simple python commandline script and a bunch of shell script templates. You can use `runserver.py` to start a new Amazon instance and feed it a shell script to automatically build your server.

    usage: runserver.py [-h] [-k ACCESS_KEY] [-s SECRET_KEY] [-r REGION] [-z ZONE]
                        -p KEY_PAIR -g SECURITY_GROUP -t
                        {m3.xlarge,m3.2xlarge,m1.small,m1.medium,m1.large,m1.xlarge,c3.large,c3.xlarge,c3.2xlarge,c3.4xlarge,c3.8xlarge,c1.medium,c1.xlarge,cc2.8xlarge,g2.2xlarge,cg1.4xlarge,m2.xlarge,m2.2xlarge,m2.4xlarge,cr1.8xlarge,hi1.4xlarge,hs1.8xlarge,t1.micro}
                        -a AMI [-m CONFIG] -b BUILD_SCRIPT [-n SERVER_NAME]
                        [-c CLUSTER] [--hosts HOSTS] [--pretend]

    Build some Amazon EC2 servers.

    optional arguments:
      -h, --help            show this help message and exit
      -k ACCESS_KEY, --access-key ACCESS_KEY
                            Your AWS access key
      -s SECRET_KEY, --secret-key SECRET_KEY
                            Your AWS secret key
      -r REGION, --region REGION
                            EC2 region
      -z ZONE, --zone ZONE  EC2 zone
      -p KEY_PAIR, --key-pair KEY_PAIR
                            EC2 key pair
      -g SECURITY_GROUP, --security-group SECURITY_GROUP
                            EC2 security group
      -t {m3.xlarge,m3.2xlarge,m1.small,m1.medium,m1.large,m1.xlarge,c3.large,c3.xlarge,c3.2xlarge,c3.4xlarge,c3.8xlarge,c1.medium,c1.xlarge,cc2.8xlarge,g2.2xlarge,cg1.4xlarge,m2.xlarge,m2.2xlarge,m2.4xlarge,cr1.8xlarge,hi1.4xlarge,hs1.8xlarge,t1.micro}, --instance {m3.xlarge,m3.2xlarge,m1.small,m1.medium,m1.large,m1.xlarge,c3.large,c3.xlarge,c3.2xlarge,c3.4xlarge,c3.8xlarge,c1.medium,c1.xlarge,cc2.8xlarge,g2.2xlarge,cg1.4xlarge,m2.xlarge,m2.2xlarge,m2.4xlarge,cr1.8xlarge,hi1.4xlarge,hs1.8xlarge,t1.micro}
                            EC2 instance type
      -a AMI, --ami AMI     EC2 AMI id
      -m CONFIG, --config-module CONFIG
                            Config module
      -b BUILD_SCRIPT, --build-script BUILD_SCRIPT
                            Build script template to use
      -n SERVER_NAME, --server-name SERVER_NAME
                            Name this server
      -c CLUSTER, --cluster CLUSTER
                            Put server in a cluster
      --hosts HOSTS         Comma-delimited list of hosts to assign to this server
      --pretend             Output the build script and don't actually create the
                            server.

## Build scripts

All the build scripts are designed to use with Ubuntu AMIs. This rig would theoretically work with any image that loads and runs a shell script from the EC2 user-data.

The build script is generated using Jinja2. `runserver.py` will load whatever variables are present in `config.py` and pass them in as context to whatever template is specified by the `-b` or `--build-script` flags.

### `newsapps/base.sh`

Build a server with the basics. Log in as the `newsapps` user. All newsapps script templates extend this.

### `newsapps/app-nginx.sh`

Build an nginx/python application server. This server is setup to handle applications deployed with our [deploy tools](https://github.com/newsapps/deploy-tools).

### `newsapps/app-cache.sh`

Build an apache/mod_wsgi application server with memcached. Includes NFS client. NFS client requires a server with the host `nfs` to be in the cluster.

### `newsapps/app.sh`

Build an apache/mod_wsgi application server. Includes NFS client. NFS client requires a server with the host `nfs` to be in the cluster.

### `newsapps/cron.sh`

Build a server for running crons and worker things. Includes NFS client, memcached and postfix. NFS client requires a server with the host `nfs` to be in the cluster.

### `newsapps/db-nfs.sh`

Build a postgres/NFS server. Be sure to label this with the `nfs` host (`--hosts nfs`).

### `newsapps/kitchensink.sh`

Build a full-stack server including postgres, apache/modwsgi, postfix, memcached.

### `newsapps/lb.sh`

Build a varnish server.

## Assets

The assets folder gets tarballed and uploaded to S3 so the boot scripts can pull it down. The boot scripts will look for `authorized_keys`, `known_hosts`, `ssh_config` and any files ending with `*.pem`. These files will be moved into `.ssh` and correctly permissioned. So you can have all ssh settings properly configured on first boot.

All files in `assets/bin` will get copied into `/usr/local/bin` on the server and properly permissioned. There are already some handy scripts in there for working with clusters. The most useful is `hosts-for-cluster`. When run as root, `hosts-for-cluster` will update the machine's hosts file with the data stored in the AWS keys assigned to each server in the current cluster. Whenever you build a new server in an existing cluster, you will need to run `hosts-for-cluster` on each server. This feature allows your to use the simple host names that you assigned to your servers on build in your application. 

The `newsapps` and `wordpress` folders in assets store customized configuration. The scripts use a function `install_file` to copy files over from these folders.

    # install_file folder_name full_path
    install_file newsapps /etc/nginx/nginx.conf

This example will copy over the `nginx.conf` file from the newsapps folder.
