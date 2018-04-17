#!/bin/bash
set -e

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

DOMAIN=${PCF_DOMAIN}

: ${DOMAIN:?must be set the DNS domain root (ex: example.cf-app.com)}
: ${KEY_BITS:=2048}
: ${DAYS:=365}

openssl req -new -x509 -nodes -sha256 -newkey rsa:${KEY_BITS} -days ${DAYS} -keyout ${DOMAIN}.key -out ${DOMAIN}.crt -config <( cat << EOF
[ req ]
prompt = no
distinguished_name = dn
x509_extensions = alternate_names

[ dn ]
C  = US
O = Pivotal
CN = *.${DOMAIN}

[ alternate_names ]
keyUsage = critical, digitalSignature
extendedKeyUsage = clientAuth, serverAuth
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid, issuer
subjectAltName = DNS:*.${DOMAIN}, DNS:*.apps.${DOMAIN}, DNS:*.sys.${DOMAIN}, DNS:*.login.sys.${DOMAIN}, DNS:*.uaa.sys.${DOMAIN}
EOF
)
