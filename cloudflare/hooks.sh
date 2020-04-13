#!/usr/bin/env bashio

SYS_TOKEN=$(bashio::config 'token')
SYS_CERTFILE=$(bashio::config 'lets_encrypt.certfile')
SYS_KEYFILE=$(bashio::config 'lets_encrypt.keyfile')

# https://github.com/lukas2511/dehydrated/blob/master/docs/examples/hook.sh

deploy_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    # This hook is called once for every domain that needs to be
    # validated, including any alternative names you may have listed.
    #
    # Parameters:
    # - DOMAIN
    #   The domain name (CN or subject alternative name) being
    #   validated.
    # - TOKEN_FILENAME
    #   The name of the file containing the token to be served for HTTP
    #   validation. Should be served by your web server as
    #   /.well-known/acme-challenge/${TOKEN_FILENAME}.
    # - TOKEN_VALUE
    #   The token value that needs to be served for validation. For DNS
    #   validation, this is what you want to put in the _acme-challenge
    #   TXT record. For HTTP validation it is the value that is expected
    #   be found in the $TOKEN_FILENAME file.

    curl -sX POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
     	-H "Authorization: Bearer $SYS_TOKEN" \
     	-H "Content-Type: application/json" \
     	--data '{"type":"TXT","name":"_acme-challenge.'$DOMAIN'","content":"'$TOKEN_VALUE'","ttl":120,"priority":10,"proxied":false}' > /dev/null

    # sleep 30 seconds to give LE time
    sleep 30
}

clean_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    # This hook is called after attempting to validate each domain,
    # whether or not validation was successful. Here you can delete
    # files or DNS records that are no longer needed.
    #
    # The parameters are the same as for deploy_challenge.

    # Get TXT record
    TXT_RECORD=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "Authorization: Bearer $SYS_TOKEN" \
        -H "Content-Type: application/json" | jq -r '.result[] | (select(.name | contains("_acme-challenge.'$DOMAIN'"))) | (select (.type | contains("TXT"))) | .id')

    # Delete TXT record
    curl -sX DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$TXT_RECORD" \
        -H "Authorization: Bearer $SYS_TOKEN" \
        -H "Content-Type: application/json" > /dev/null
}

deploy_cert() {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"

    # This hook is called once for each certificate that has been
    # produced. Here you might, for instance, copy your new certificates
    # to service-specific locations and reload the service.
    #
    # Parameters:
    # - DOMAIN
    #   The primary domain name, i.e. the certificate common
    #   name (CN).
    # - KEYFILE
    #   The path of the file containing the private key.
    # - CERTFILE
    #   The path of the file containing the signed certificate.
    # - FULLCHAINFILE
    #   The path of the file containing the full certificate chain.
    # - CHAINFILE
    #   The path of the file containing the intermediate certificate(s).
    # - TIMESTAMP
    #   Timestamp when the specified certificate was created.

     cp -f "$FULLCHAINFILE" "/ssl/$SYS_CERTFILE"
     cp -f "$KEYFILE" "/ssl/$SYS_KEYFILE"
}


HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_challenge|clean_challenge|deploy_cert)$ ]]; then
    "$HANDLER" "$@"
fi