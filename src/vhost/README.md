# General vhost resources

Contains scripts for deploying a debian-based test machine to a lab-environment.

## Usage

Clone the repository, set `.env` appropriately, and invoke `run.sh` as the root user.

```
Values in this template are set arbitrarily, but they do illustrate somewhat
sane examples.

The general assumption for networking here is as follows:
Physical network(s):    192.168.0.0 /16
Container network(s):   172.16.0.0  /12
Virtual network(s):     10.0.0.0    /8
 
There are two interfaces:
1. A physical network and a corresponding interface (IF1)
2. A virtual network and a corresponding interface (IF2)

Each network range should also have its own subdomain set in DNS.
This means resolving "vhost" would be via 'vhost.subdomain.domain.tld',
using either static binds or auto-registration via DHCP-server.

Remember to update MAC-binds if re-deploying as vNIC IDs are likely to change.
```
