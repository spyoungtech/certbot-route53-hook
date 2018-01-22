certbot-route-53-hook v0.1
==========================

A pre-auth and post-auth hook for certbot's manual plugin to satisfy DNS challenges by creating the required recordset
via AWS Route 53 and ``boto3``. When used as cleanup hook, it will delete the previously created record set.

Useful for using certbot to request or renew certs for systems that are not publicly accessible, such as those that may sit on an internal network. It is also suitable for automated non-interactive use.


Prerequisites
-------------

1. A domain name with DNS managed by Route53
2. A set of AWS IAM credentials with Route53 permissions
3. Certbot
4. A Python3 environment with ``boto3`` installed (with AWS credentials configured)
5. The ID of your hosted zone(s) you want to use from Route53 (optional) 

   1. If the ID is not provided, the hook will attempt to find the zone id through the Route53 boto3 client


How to use
----------

Simply supply the path to ``certbot_hook.py`` for the ``--manual-auth-hook`` and ``--manual-cleaup-hook`` options to the certbot command. You should also specify ``--preferred-challenges`` as ``dns`` and the plugin as manual by supplying ``--manual``

For example to request a new certificate

::

    certbot certonly --preferred-challenges=dns --manual --manual-auth-hook=/path/to/certbot_hook.py --manual-cleanup-hook=/path/to/certbot_hook.py -d secure.example.com


Then to renew, you can simply use ``certbot renew``.


NOTE: the hook is called even on dry-runs.


Other notes
-----------


Using the hook noninteractively
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To use the hook noninteractively, you should supply the noninteractive flag ``-n`` and the ``--manual-public-ip-logging-ok`` option.


Specifying the hosted zone ID
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It's recommended that you specify the zone id(s) you need explicitly. If you do not, the hook will attempt to use the boto3 Route53 client to get the ID.

The hook will attempt to use the following methods in order to get the zone ID:

By Environment Variable
"""""""""""""""""""""""

If you only use one hosted zone with certbot, you can set the ``CERTBOT_ZONE_ID`` environment variable.

::


    export CERTBOT_ZONE_ID=ABCD1234567890


By config file
""""""""""""""

Alongside the ``certbot_hook.py`` file place a file named ``config.py`` (example template included in repo). The contents should contain a single variable ``zone_map`` which is a Python dictionary containing a mapping of zone names to zone IDs. This method supports multiple zones. For example

::

    zone_map = {
        'example.com': 'ABCD1234567890'
    }


Automatically via boto3
"""""""""""""""""""""""

If the zone ID is not found with the above methods, the hook will request a list of all your hosted zones and find the zone it needs.

This feature is experimental. Further, there is a known issue where identifying the zone ID might fail if you have more
than 100 hosted zones. If you have more than 100 hosted zones, you may want to use the config file option instead.




Configuring AWS credentials
^^^^^^^^^^^^^^^^^^^^^^^^^^^

In order to connect to AWS resources, you need to supply credentials. You can do this in the form of environment variables or through a credentials file. An easy way to create your credentials file is using the awscli.

Install aws cli
"""""""""""""""

::

    pip3 install awscli

Cofigure credentials
""""""""""""""""""""

With awscli installed, simply call the ``configure`` command to get an interactive prompt for setting up your credentials.

::

    aws configure

You will be prompted to provide your access ID and secret key.

This portion of the documentation is provided as a convenience. If you have issues with credentials, please see the Amazon docs.


Similar Work
------------

`certbot-route53`_ is a shell script that does pretty much exactly the same thing.

.. _certbot-route53: https://github.com/jed/certbot-route53