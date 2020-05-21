#!/usr/bin/env bashio
. cloudflare_api.sh

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir

# Let's encrypt
LE_UPDATE="0"
WAIT_TIME=$(bashio::config 'seconds')

function lets_encrypt_renew() {
	local domain_args=()
	local domains=$(bashio::config 'domains')

	# Prepare domain for Let's Encrypt
	for domain in ${domains}; do
		domain_args+=("--domain" "${domain}")
	done		
	
	dehydrated --cron --hook ./hooks.sh --challenge dns-01 "${domain_args[@]}" --out "${CERT_DIR}" --config "${WORK_DIR}/config" || true
	LE_UPDATE="$(date +%s)"
}

# Register/generate certificate if terms accepted
if bashio::config.true 'lets_encrypt.accept_terms'; then
	# Init folder structs
	mkdir -p "${CERT_DIR}"
	mkdir -p "${WORK_DIR}"
	
	# Generate new certs
	if [ ! -d "${CERT_DIR}/live" ]; then
		# Create empty dehydrated config file so that this dir will be used for storage
		touch "${WORK_DIR}/config"
		
		dehydrated --register --accept-terms --config "${WORK_DIR}/config"
	elif [ -e "${WORK_DIR}/lock" ]; then
		# Some user reports issue with lock files/cleanup
		rm -rf "${WORK_DIR}/lock"
		bashio::log.warning "Reset dehydrated lock file"
	fi
fi

# Get initial IP
CURRENT_IP=$(get_ip)

# If there is an IP update records
if bashio::var.has_value "$CURRENT_IP"; then
	check_a_records $CURRENT_IP
fi

while true; do
	REFRESH_IP=$(get_ip)

	if bashio::var.has_value "$REFRESH_IP"; then
		if bashio::var.equals "$CURRENT_IP" "$REFRESH_IP"; then
			bashio::log.info "NO CHANGE: $REFRESH_IP"
		else
			bashio::log.info "CHANGE: $REFRESH_IP"
			CURRENT_IP=$REFRESH_IP
			check_a_records $REFRESH_IP
		fi

		now="$(date +%s)"
		if bashio::config.true 'lets_encrypt.accept_terms' && [ $((now - LE_UPDATE)) -ge 43200 ]; then
			lets_encrypt_renew
		fi
	else
		bashio::log.info "NO IP FOUND"
	fi

	sleep "$WAIT_TIME"
done