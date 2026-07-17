#!/usr/bin/env bash
# Fetch a Slack thread and save as markdown to .raw/
# Usage: slack-fetch-thread.sh <slack-url> [output-slug]
# Token is read from macOS Keychain (service: slack-api-token)

set -euo pipefail

URL="${1:?Usage: slack-fetch-thread.sh <slack-url> [output-slug]}"
SLUG="${2:-}"

TOKEN=$(security find-generic-password -s "slack-api-token" -w 2>/dev/null) || {
  echo "ERROR: No slack-api-token found in Keychain" >&2
  exit 1
}

# Parse channel and thread_ts from URL
CHANNEL=$(echo "$URL" | grep -oE 'archives/([^/]+)' | cut -d/ -f2)
MSG_TS=$(echo "$URL" | grep -oE 'p[0-9]+' | head -1 | sed 's/^p//' | sed 's/\(.\{10\}\)/\1./')
THREAD_TS=$(echo "$URL" | grep -oE 'thread_ts=[0-9.]+' | cut -d= -f2 || true)
THREAD_TS="${THREAD_TS:-$MSG_TS}"

OUTFILE=$(mktemp)

curl -s "https://slack.com/api/conversations.replies?channel=${CHANNEL}&ts=${THREAD_TS}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -o "$OUTFILE"

python3 - "$OUTFILE" "$URL" "$CHANNEL" "$SLUG" "$TOKEN" << 'PYEOF'
import json, os, sys, subprocess, re
from datetime import datetime

outfile, url, channel, slug, token = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]

with open(outfile) as f:
    data = json.load(f)

if not data.get('ok'):
    print(f"ERROR: Slack API returned: {data.get('error')}", file=sys.stderr)
    sys.exit(1)

messages = data['messages']

# Resolve user IDs
user_ids = set()
for msg in messages:
    if 'user' in msg:
        user_ids.add(msg['user'])
    user_ids.update(re.findall(r'<@(U[A-Z0-9]+)>', msg.get('text', '')))

user_map = {}
for uid in user_ids:
    resp = subprocess.run(['curl', '-s', f'https://slack.com/api/users.info?user={uid}',
                          '-H', f'Authorization: Bearer {token}'], capture_output=True, text=True)
    udata = json.loads(resp.stdout)
    if udata.get('ok'):
        profile = udata['user'].get('profile', {})
        user_map[uid] = profile.get('real_name', udata['user'].get('name', uid))
    else:
        user_map[uid] = uid

# Get channel name
resp = subprocess.run(['curl', '-s', f'https://slack.com/api/conversations.info?channel={channel}',
                      '-H', f'Authorization: Bearer {token}'], capture_output=True, text=True)
chan_data = json.loads(resp.stdout)
channel_name = chan_data.get('channel', {}).get('name', channel) if chan_data.get('ok') else channel

# Format
output_lines = []
for msg in messages:
    ts = datetime.fromtimestamp(float(msg['ts'])).strftime('%Y-%m-%d %H:%M')
    user = user_map.get(msg.get('user', ''), msg.get('user', 'unknown'))
    text = msg.get('text', '')
    for uid, name in user_map.items():
        text = text.replace(f'<@{uid}>', f'@{name}')
    text = re.sub(r'<(https?://[^|>]+)\|([^>]+)>', r'[\2](\1)', text)
    text = re.sub(r'<(https?://[^>]+)>', r'\1', text)
    output_lines.append(f'**{user}** ({ts}):\n{text}\n')

result = f"---\nsource_url: {url}\nchannel: #{channel_name}\nfetched: {datetime.now().strftime('%Y-%m-%d')}\n---\n\n# Slack Thread: #{channel_name}\n\n" + '\n'.join(output_lines)

print(result)
os.unlink(outfile)
PYEOF
