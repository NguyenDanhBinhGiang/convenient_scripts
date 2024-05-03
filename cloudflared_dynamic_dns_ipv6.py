#!/usr/bin/env python3
import requests
import subprocess
import datetime

DOMAIN = 'example.com'
SUBDOMAIN_TO_UPDATE = [
    'place.the.sub.domains.needed.to.update.here',
    'subdomain1.example.com',
    'subdomain2.example.com',
]
API_KEY = "<YOUR_CLOUDFLARE_API_KEY>"


def time_data():
    return datetime.datetime.now().strftime("[%Y-%m-%d %H:%M:%S]: ")


# ONLY WORKS ON LINUX
# There has to be a better way, but im lazy and this will do for now
stdout_data = subprocess.getoutput(r'ip -6 addr | grep "scope global.*noprefixroute" | head -1')
assert stdout_data, "Cannot get ipv6"
stdout_data = stdout_data.strip()
assert stdout_data.startswith('inet6')
ipv6 = stdout_data[stdout_data.index('inet6 ') + len('inet6 '): stdout_data.index(' scope')]
if '/' in ipv6:
    ipv6 = ipv6[:ipv6.index('/')]
print(f"{time_data()}IPv6 found: {ipv6}")

header = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

# validate the api key
validate = requests.get("https://api.cloudflare.com/client/v4/user/tokens/verify", headers=header)
validate = validate.json()
assert validate.get('success'), "API key not valid"

# get the correct zone
zones = requests.get("https://api.cloudflare.com/client/v4/zones", headers=header)
assert zones.status_code // 100 == 2, f"API Error: {zones.text}"
zones = zones.json()
assert zones.get('success'), f"Error while fetching zones: {zones.get('errors')}\n {zones.get('messages')}"
zone_id = None
for zone in zones.get('result'):
    if zone.get('name') == DOMAIN:
        zone_id = zone.get('id')
assert zone_id, "Cannot find zone"

# get dns records
all_dns_records = requests.get(f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records", headers=header)
all_dns_records = all_dns_records.json()
# filter out the records to update, note that it will only update AAAA records
dns_record_to_update = [rec for rec in all_dns_records.get('result')
                        if rec.get('name') in SUBDOMAIN_TO_UPDATE
                        and rec.get('type') == 'AAAA']

# loop through the records to update them
for rec in dns_record_to_update:
    dns_record_id = rec.get('id')
    payload = {
        "content": ipv6,
        "proxied": False,
        "comment": f"Automatically updated at {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
    }
    patch_result = requests.patch(f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{dns_record_id}",
                                  headers=header, json=payload)
    assert patch_result.status_code // 100 == 2, f"API error: {patch_result.text}"
    patch_result = patch_result.json()
    assert patch_result.get('success'), f"Error while updating dns record: " \
                                        f"{patch_result.get('errors')}\n{patch_result.get('messages')}"
    print(f"{time_data()}Updated {rec.get('name')}")
