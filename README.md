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
