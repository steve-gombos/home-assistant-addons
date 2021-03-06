# Cloudflare

Automatically update your Cloudflare DNS IP address.  Issues a Let's Encrypt cert for your domains.

## Setup

Before installing the add-on a couple of things need to be done.

### 1. Cloudflare 
  - Sign up for a free Cloudflare account.
  - Add your base domain (no need to create any DNS records).
  - Make a note of the CloudFlare name servers.
  - Option 1: Set the free SSL option under the crypto menu to "Full (strict)" and enable Universal SSL.
  - Option 2: Turn off the free SSL option under the Crypto menu (SSL to Off & Disable Universal SSL).

### 2. Domain Registrar
  - Change nameservers for your domain to point to Cloudflare.

### 3. Home Router
  - Optional: Forward desired public facing port (TCP & UDP) to your Hass.io local IP & port (default local port is 8123).
    - Example: Forward port 443 to local port if you want to access externally without specifying a port. i.e *https://mydomain.com* rather than *https://mydomain.com:8123*

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Add the following repository: https://github.com/steve-gombos/home-assistant-addons
3. Refresh the add-on page
4. Find the "Cloudflare" add-on and click it.
5. Click on the "INSTALL" button.

## Configuration

Add-on configuration:

```yaml
lets_encrypt:
  accept_terms: true
  certfile: fullchain.pem
  keyfile: privkey.pem
token: sdfj-2131023-dslfjsd-12321
zone: mydomain.com
domains:
  - test.mydomain.com
proxy: false
seconds: 300
```

### Option group `lets_encrypt`

The following options are for the option group: `lets_encrypt`. These settings
only apply to Let's Encrypt SSL certificates.

#### Option `lets_encrypt.accept_terms`

Once you have read and accepted the Let's Encrypt [Subscriber Agreement](https://letsencrypt.org/repository/), change value to `true` in order to use Let's Encrypt services.

#### Option `lets_encrypt.certfile`

The name of the certificate file generated by Let's Encrypt. The file is used for SSL by Home Assistant add-ons and is recommended to keep the filename as-is (`fullchain.pem`) for compatibility.

**Note**: *The file is stored in `/ssl/`, which is the default for Home Assistant*

#### Option `lets_encrypt.keyfile`

The name of the private key file generated by Let's Encrypt. The private key file is used for SSL by Home Assistant add-ons and is recommended to keep the filename as-is (`privkey.pem`) for compatibility.

**Note**: *The file is stored in `/ssl/`, which is the default for Home Assistant*

### Option: `token`

The Cloudflare API token found at the bottom right of your zone page.  Create a custom API token using the following permissions:
* Zone.Zone.Edit
* Zone.DNS.Edit

### Option: `zone`

The Zone Name for your domain on Cloudflare. 

### Option: `domains`

A list of domains to be added or updated in your zone. An acceptable naming convention is `test.mydomain.com`.

### Option: `proxy`

Enables [Cloudflare Edge Proxy](https://support.cloudflare.com/hc/en-us/articles/205177068) for your domains. Optional, defaults to `false`.

### Option: `seconds`

The number of seconds to wait before updating Cloudflare domains and attempting to renew Let's Encrypt certificates.

## Inspiration

* https://github.com/home-assistant/hassio-addons/tree/master/duckdns
* https://github.com/PhrantiK/hassio-addons/tree/master/letsdnsocloud