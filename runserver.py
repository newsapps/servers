#!/usr/bin/env python
import os

PWD = os.path.abspath(os.path.dirname(__file__))

from jinja2 import Environment, FileSystemLoader
env = Environment(
    loader=FileSystemLoader(PWD + '/boot-scripts'))

INSTANCE_TYPES = ['m3.xlarge', 'm3.2xlarge', 'm1.small', 'm1.medium', 'm1.large', 'm1.xlarge',
'c3.large', 'c3.xlarge', 'c3.2xlarge', 'c3.4xlarge', 'c3.8xlarge', 'c1.medium',
'c1.xlarge', 'cc2.8xlarge', 'g2.2xlarge', 'cg1.4xlarge', 'm2.xlarge',
'm2.2xlarge', 'm2.4xlarge', 'cr1.8xlarge', 'hi1.4xlarge', 'hs1.8xlarge',
't1.micro',]


def render(template_name, template_dict):
    template = env.get_template(template_name)
    return template.render(**template_dict)


if __name__ == '__main__':
    from clint.textui import puts, colored, indent
    import argparse
    import random
    import string
    import io
    import tarfile
    import boto.ec2
    from boto.s3.connection import S3Connection
    from boto.s3.key import Key

    parser = argparse.ArgumentParser(description='Build some Amazon EC2 servers.')
    parser.add_argument("-k", "--access-key", dest="access_key",
                        help="Your AWS access key")
    parser.add_argument("-s", "--secret-key", dest="secret_key",
                        help="Your AWS secret key")

    parser.add_argument("-r", "--region", dest="region",
                        help="EC2 region", default="us-east-1")
    parser.add_argument("-z", "--zone", dest="zone",
                        help="EC2 zone")

    parser.add_argument("-p", "--key-pair", dest="key_pair",
                        help="EC2 key pair", required=True)
    parser.add_argument("-g", "--security-group", dest="security_group",
                        help="EC2 security group", required=True)
    parser.add_argument("-t", "--instance", dest="instance",
                        help="EC2 instance type", required=True,
                        choices=INSTANCE_TYPES)
    parser.add_argument("-a", "--ami", dest="ami",
                        help="EC2 AMI id", required=True)

    parser.add_argument("-m", "--config-module", dest="config",
                        help="Config module", default='config')
    parser.add_argument("-b", "--build-script", dest="build_script",
                        help="Build script template to use", required=True)

    parser.add_argument("-n", "--server-name", dest="server_name",
                        help="Name this server")
    parser.add_argument("-c", "--cluster", dest="cluster",
                        help="Put this server in a cluster")

    args = parser.parse_args()

    try:
        config = __import__(args.config)
    except ImportError:
        parser.error("Cannot load the module '%s'" % args.config)

    if args.cluster:
        if(not hasattr(config, 'SERVER_TYPES')
                or not config.SERVER_TYPES.get(args.build_script, False)):
            parser.error("To build this server as part of a cluster, the build script name '%s' should be in the SERVER_TYPES dictionary in the module '%s'" % (args.build_script, args.module))

    if args.access_key:
        ec2 = boto.ec2.connect_to_region(
            args.region, aws_access_key_id=args.access_key,
            aws_secret_access_key=args.secret_key)
        s3 = S3Connection(args.access_key, args.secret_key)
    else:
        ec2 = boto.ec2.connect_to_region(args.region)
        s3 = S3Connection()

    # store assets
    if s3.lookup(config.ASSET_BUCKET):
        bucket = s3.get_bucket(config.ASSET_BUCKET)
    else:
        bucket = s3.create_bucket(config.ASSET_BUCKET)

    s3_key = Key(bucket)
    s3_key.key = "assets-%s.tgz" % ''.join(random.choice(string.ascii_uppercase + string.digits) for x in range(8))
    with io.BytesIO() as data_stream:
        with tarfile.open(fileobj=data_stream, mode='w:gz') as tarball:
            tarball.add(PWD + '/assets')
        data_stream.seek(0)
        s3_key.set_contents_from_file(data_stream)

    template_dict = config.__dict__.copy()
    template_dict['ASSET_URL'] = s3_key.generate_url(600)
    template_dict['SERVER_NAME'] = args.server_name

    print render(args.build_script, template_dict)
    #reservation = ec2.run_instances(
        #image_id=args.ami,
        #key_name=args.key_pair,
        #user_data=render(args.build_script, template_dict),
        #security_groups=args.security_group.split(','),
        #instance_type=args.instance
    #)

    #for instance in reservation.instances:
        #instance.add_tag('Name', args.server_name)
        #if args.cluster:
            #hosts = map(lambda x: x.strip(), args.hosts.split(','))
            #if args.server_name not in hosts:
                #hosts.insert(0, args.server_name)
            #instance.add_tag('Cluster', args.cluster)
            #instance.add_tag('Hosts', ', '.join(hosts))
            #instance.add_tag('Type', SERVER_TYPES[args.build_script])
