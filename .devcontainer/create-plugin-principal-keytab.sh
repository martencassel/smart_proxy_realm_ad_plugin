#!/bin/bash

# 
# We need a keytab so that the plugin can authenticate
# to active directory, see realm_ad.yml,
#
# :principal: realm-proxy@EXAMPLE.COM
# :keytab_path:  /etc/foreman-proxy/realm_ad.keytab
#
# You need an Administrative account to create this account.
#

>ktutil
addent -password -p Administrator@EXAMPLE.COM -k 1 -e RC4-HMAC
- enter password for username -

wkt realm_ad.keytab
q
> kdestroy
> kinit Administrator@EXAMPLE.COM -k -t realm_ad.keytab; 
> klist
Ticket cache: KEYRING:persistent:1000:1000
Default principal: Administrator@EXAMPLE.COM

Valid starting       Expires              Service principal
2017-01-27 10:30:00  2017-01-27 20:30:00  krbtgt/EXAMPLE.COM@EXAMPLE.COM
	renew until 2017-02-03 10:30:00

