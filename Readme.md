# RouterOs snmp script runner

Runs script on RouterOs snmp agent (MikroTik Router).

## Requirements

* perl
* net-snmp


## Use

### Scripts on router

`/system script print` command lists scripts availabe on router. E.g.

```
[admin@hgw] /system script> print
Flags: I - invalid
 0   name="disable-internet-marc" owner="admin" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon dont-require-permissions=no last-started=mar/22/2020 18:34:59 run-count=4 source=/ip firewall filter enable 13

 1   name="enable-internet-marc" owner="admin" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon dont-require-permissions=no last-started=mar/22/2020 18:37:43 run-count=6 source=/ip firewall filter disable 13
```

How to create scripts? See https://wiki.mikrotik.com/wiki/Manual:Scripting


### Run from snmp manager

Make sure that net-snmp is configured with the correct community (snmp v1 and v2) or username / password(s) (authentication and encryption password).
This community or user should have write privileges. Therefore it's advisable to use snmp v3 and to restrict access on agent to the manager.
`snmpconf` can help create a snmp config file.

```
[admin@hgw] /snmp community> print value-list
                       name: public          private
                  addresses: 192.168.20.2/32 192.168.20.2/32
                   security: none            authorized
                read-access: yes             yes
               write-access: no              yes
    authentication-protocol: MD5             MD5
        encryption-protocol: DES             DES
    authentication-password:                 ******
        encryption-password:                 ******
```

Change hostname of router (agent) in script:

```
use constant AGENT => 'gateway';
```
 
Change 'gateway' info the hostname or ip address of your router.


```
$ run_script_on_gateway.pl

Usage /home/marc/bin/run_script_on_gateway.pl <script name>
      /home/marc/bin/run_script_on_gateway.pl -l


$ run_script_on_gateway.pl -l

disable-internet-marc
enable-internet-marc

$ run_script_on_gateway.pl disable-internet-marc

SNMPv2-SMI::enterprises.14988.1.1.18.1.1.2.3 = ""

```

