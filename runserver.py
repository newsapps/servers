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
    from clint.textui import puts, colored, indent, columns
    import argparse
    import random
    import string
    import io
    import tarfile
    import boto.ec2
    import time
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
                        help="Put server in a cluster")
    parser.add_argument("--hosts", dest="hosts", default='',
                        help="Comma-delimited list of hosts to assign to this server")

    parser.add_argument("--pretend", dest="pretend", action='store_true',
                        help="Output the build script and don't actually create the server.")

    args = parser.parse_args()

    try:
        config = __import__(args.config)
    except ImportError:
        parser.error("Cannot load the module '%s'" % args.config)

    if args.cluster:
        if(not hasattr(config, 'SERVER_TYPES')
                or not config.SERVER_TYPES.get(args.build_script, False)):
            parser.error("To build this server as part of a cluster, the build script name '%s' should be in the SERVER_TYPES dictionary in the module '%s'" % (args.build_script, args.config))

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
    s3_key.key = "assets-%s.tgz" % ''.join(random.choice(
        string.ascii_uppercase + string.digits) for x in range(8))
    with io.BytesIO() as data_stream:
        with tarfile.open(fileobj=data_stream, mode='w:gz') as tarball:
            tarball.add(PWD + '/assets', 'assets')
        data_stream.seek(0)
        s3_key.set_contents_from_file(data_stream)

    template_dict = config.__dict__.copy()
    template_dict['ASSET_URL'] = s3_key.generate_url(600)
    template_dict['ASSET_KEY'] = s3_key.key
    template_dict['SERVER_NAME'] = args.server_name

    tags = {'Name': args.server_name}
    if args.cluster:
        if args.hosts:
            hosts = map(lambda x: x.strip(), args.hosts.split(','))
        else:
            hosts = list()
        if args.server_name not in hosts:
            hosts.insert(0, args.server_name)
        tags['Cluster'] = args.cluster
        tags['Hosts'] = ', '.join(hosts)
        tags['Type'] = config.SERVER_TYPES[args.build_script]

    if args.pretend:
        col1 = 25
        col2 = 30
        build_filename = 'build.sh'
        with open(build_filename, 'w') as fp:
            fp.write(render(args.build_script, template_dict))
        puts("")
        puts(colored.red("Just pretend mode"))
        puts("")
        with indent(4, quote=colored.blue(' >')):
            puts("Wrote build script to '%s'" % build_filename)
        puts("")
        puts("Would start a server with these settings:")
        with indent(4):
            puts(columns(
                [colored.blue('AMI'), col1],
                [args.ami, col2]))
            puts(columns(
                [colored.blue('Key Pair'), col1],
                [args.key_pair, col2]))
            puts(columns(
                [colored.blue('Security groups'), col1],
                [args.security_group, col2]))
            puts(columns(
                [colored.blue('Size'), col1],
                [args.instance, col2]))
            puts(columns(
                [colored.blue('Region'), col1],
                [args.region, col2]))

        puts("")
        puts("And add these tags:")
        with indent(4):
            for k, v in tags.iteritems():
                puts(columns(
                    [colored.blue(k), col1],
                    [v, col2]))
    else:
        puts("")
        puts(colored.red("For real mode"))
        puts("")
        with indent(4, quote=colored.blue(' >')):
            puts("Starting instance")

        reservation = ec2.run_instances(
            image_id=args.ami,
            key_name=args.key_pair,
            user_data=render(args.build_script, template_dict),
            security_groups=args.security_group.split(','),
            instance_type=args.instance
        )

        # add tags
        for instance in reservation.instances:
            for k, v in tags.iteritems():
                instance.add_tag(k, v)

        for instance in reservation.instances:
            s3_key = Key(bucket)
            s3_key.key = '%s._cc_' % instance.id
            s3_key.set_contents_from_string(
                'running', {'Content-Type': 'text/plain'}, replace=True)

            while instance.state != 'running':
                time.sleep(3)
                instance.update()

            with indent(4, quote=colored.blue(' >')):
                puts("Building instance")

            state = 'running'
            while state == 'running':
                time.sleep(3)
                if s3_key.exists():
                    state = s3_key.get_contents_as_string()
                else:
                    break

            with indent(4, quote=colored.blue(' >')):
                puts("Build complete")
                puts(instance.public_dns_name)
