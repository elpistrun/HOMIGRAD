import json
import time
from pathlib import Path

import requests
from pypresence import Presence

CONFIG_PATH = Path(__file__).parent / "config.json"
config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))

CLIENT_ID = config.get("discord_app_id", "")
BACKEND_URL = f"http://localhost:{config.get('port', 3567)}/api/status"
UPDATE_INTERVAL = 15  # секунд (Discord rate limit)

if not CLIENT_ID or CLIENT_ID == "YOUR_DISCORD_APP_ID_HERE":
    print("[RPC] Set discord_app_id in config.json!")
    exit(1)

RPC = Presence(CLIENT_ID)
last_data = None


def build_presence(data):
    game_name = config.get("game_name", "Homigrad")

    if not data or not data.get("servers"):
        return {
            "details": game_name,
            "state": "Разрабатывает",
            "large_image": "logo",
            "large_text": game_name,
            "start": int(time.time())
        }

    servers = data["servers"]
    total_players = sum(s.get("players", 0) for s in servers)
    total_max = sum(s.get("maxPlayers", 0) for s in servers)
    server = servers[0]

    return {
        "details": f"{server['map']} — {server.get('hostname') or server['ip']}",
        "state": f"Игроков: {total_players}/{total_max}",
        "large_image": "logo",
        "large_text": f"{game_name} — {server['map']}",
        "small_image": "playing",
        "small_text": f"Серверов: {len(servers)}",
        "party_size": [total_players, total_max],
        "start": int(time.time()),
        "instance": False
    }


def update_presence():
    global last_data
    try:
        resp = requests.get(BACKEND_URL, timeout=5)
        data = resp.json()

        data_str = json.dumps(data, sort_keys=True)
        if data_str == last_data:
            return
        last_data = data_str

        presence = build_presence(data)
        RPC.update(**presence)
        print(f"[RPC] Updated: {presence['details']} | {presence['state']}")
    except requests.ConnectionError:
        pass  # бэкенд ещё не запущен
    except Exception as e:
        print(f"[RPC] Error: {e}")


def main():
    print(f"[RPC] Connecting to Discord (App: {CLIENT_ID})...")
    try:
        RPC.connect()
    except Exception as e:
        print(f"[RPC] Failed to connect. Is Discord running?")
        print(f"[RPC] Error: {e}")
        return

    print("[RPC] Connected!")
    update_presence()

    while True:
        time.sleep(UPDATE_INTERVAL)
        update_presence()


if __name__ == "__main__":
    main()
