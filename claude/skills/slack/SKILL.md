---
name: slack
description: Send Slack messages by reusing auth from the local Slack desktop app
argument-hint: <workspace> <#channel> <message> [--thread <ts>]
---

# Slack Message Sender

Extract auth credentials from the local Slack desktop app and send messages via the Slack Web API.

## Arguments

```
/slack <workspace_keyword> <#channel-name> <message> [--thread <ts>]
```

- `workspace_keyword`: Partial match for workspace name (e.g. "local", "bevalley")
- `#channel-name`: Channel name (with or without `#`)
- `message`: Message body to send
- `--thread <ts>`: Parent message `ts` for thread replies

## Procedure

### STEP 1: Token Extraction

#### 1a. Decrypt the `d` cookie

```python
import sqlite3, os, hashlib, subprocess, re
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

# Retrieve decryption key from system keyring
result = subprocess.run(
    ["secret-tool", "lookup", "server", "Chromium Keys", "user", "Chromium Safe Storage"],
    capture_output=True, text=True, timeout=5
)
password = result.stdout.strip()  # e.g. "P+ukb1YlPJklAjxE/p3vPA=="

# Read encrypted d cookie from Cookies SQLite
db_path = os.path.expanduser("~/.config/Slack/Cookies")
conn = sqlite3.connect(db_path)
cur = conn.cursor()
cur.execute("SELECT encrypted_value FROM cookies WHERE name='d' AND host_key LIKE '%slack%'")
enc_val = cur.fetchone()[0]
conn.close()

# Decrypt (strip 3-byte v11 prefix)
encrypted = enc_val[3:]
key = hashlib.pbkdf2_hmac('sha1', password.encode('utf-8'), b'saltysalt', 1, dklen=16)
iv = b' ' * 16
cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
decryptor = cipher.decryptor()
decrypted = decryptor.update(encrypted) + decryptor.finalize()

# PKCS7 unpadding
pad_len = decrypted[-1]
decrypted = decrypted[:-pad_len]
raw = decrypted.decode('utf-8', errors='replace')

# Extract from xoxd- onward (garbage bytes precede it)
d_cookie = raw[raw.find('xoxd-'):]
```

#### 1b. Identify the workspace

```python
import json

with open(os.path.expanduser("~/.config/Slack/storage/root-state.json")) as f:
    state = json.load(f)

workspaces = state.get("workspaces", {})
# { "T01G5HFUV8A": { "domain": "local-llc", "name": "合同会社LOCAL", ... }, ... }

# Filter by keyword
keyword = "local"  # from argument
match = None
for tid, ws in workspaces.items():
    if keyword.lower() in ws.get("domain", "").lower() or keyword.lower() in ws.get("name", "").lower():
        match = ws
        break
domain = match["domain"]  # e.g. "local-llc"
```

#### 1c. Obtain the `xoxc-` token

```python
import urllib.request

url = f"https://{domain}.slack.com/"
req = urllib.request.Request(url)
req.add_header('Cookie', f'd={d_cookie}')
req.add_header('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36')

with urllib.request.urlopen(req, timeout=15) as resp:
    html = resp.read().decode('utf-8', errors='replace')

xoxc_token = re.search(r'xoxc-[a-zA-Z0-9\-]+', html).group(0)
```

### STEP 2: Find the channel

```python
import urllib.parse

data = urllib.parse.urlencode({
    'token': xoxc_token,
    'types': 'public_channel,private_channel',
    'limit': 200,
}).encode()

req = urllib.request.Request(f'https://{domain}.slack.com/api/conversations.list', data=data)
req.add_header('Cookie', f'd={d_cookie}')
req.add_header('Content-Type', 'application/x-www-form-urlencoded')

with urllib.request.urlopen(req, timeout=15) as resp:
    result = json.loads(resp.read())

channel_name = "902-personal-notify"  # from argument (strip leading #)
channel_id = None
for ch in result.get('channels', []):
    if ch['name'] == channel_name:
        channel_id = ch['id']
        break
```

Paginate using `response_metadata.next_cursor` if the channel is not found in the first page.

### STEP 3: Send the message

```python
params = {
    'token': xoxc_token,
    'channel': channel_id,
    'text': message,
}
# For thread replies
if thread_ts:
    params['thread_ts'] = thread_ts

data = urllib.parse.urlencode(params).encode()

req = urllib.request.Request(f'https://{domain}.slack.com/api/chat.postMessage', data=data)
req.add_header('Cookie', f'd={d_cookie}')
req.add_header('Content-Type', 'application/x-www-form-urlencoded')

with urllib.request.urlopen(req, timeout=15) as resp:
    result = json.loads(resp.read())

# result['ok'] == True on success, result['ts'] is the message timestamp
```

## Notes

- The Slack desktop app must be signed in
- The `d` cookie expires on logout or session expiry — re-extract when that happens
- Session tokens should not be persisted long-term (short-lived `/tmp` cache is acceptable)
- Sending works regardless of which workspace the desktop client is currently viewing
