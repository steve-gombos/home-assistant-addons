#!/usr/bin/env bashio

TOKEN=$(bashio::config 'token')
ZONE=$(bashio::config 'zone')
DOMAINS=$(bashio::config 'domains')

bashio::log.info "Zone: $ZONE"

function get_ip(){
	echo "$(curl -s "https://wtfismyip.com/text")"
}

function get_zone_id() {
	local zone_id=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones?name=${ZONE}" \
		-H "Authorization: Bearer $TOKEN" \
		-H "Content-Type: application/json" | jq -r '.result[] | .id')

	echo "$zone_id"
}

function get_a_record() {
	local name=$1
	local a_record=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=${name}" \
		-H "Authorization: Bearer $TOKEN" \
		-H "Content-Type: application/json" | jq -r '.result[] | (select (.type | contains("A"))) | .id')

	echo "$a_record"
}

function create_a_record() {
	local domain=$1
	local ip=$2
	curl -sX POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
		-H "Authorization: Bearer $TOKEN" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"'$domain'","content":"'$ip'","proxied":false}' -o /dev/null

	bashio::log.info "Created A Record - $domain"
}

function update_a_record() {
	local domain=$1
	local a_record=$2
	local ip=$3
	curl -sX PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$a_record" \
		-H "Authorization: Bearer $TOKEN" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"'$domain'","content":"'$ip'","proxied":false}' -o /dev/null
		
	bashio::log.info "Updated A Record - $domain"
}

function check_a_records() {
	local ip=$1
	if bashio::var.is_empty "$ip"; then
		bashio::log.error "No IP Address found."
	else
		for domain in ${DOMAINS}; do
			local a_record=$(get_a_record "$domain")
			if bashio::var.is_empty "$a_record"; then
				create_a_record $domain $ip
			else
				update_a_record $domain $a_record $ip
			fi
		done
	fi	
}

export ZONE_ID=$(get_zone_id)