import json
import time
import asyncio
import random
import string
import threading
from pathlib import Path

from flask import Flask, request, jsonify
import discord
from discord import app_commands

CONFIG_PATH = Path(__file__).parent / "config.json"
DATA_PATH = Path(__file__).parent / "data.json"
config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))

app = Flask(__name__)

# ========================
# Данные
# ========================

def load_data():
    if DATA_PATH.exists():
        return json.loads(DATA_PATH.read_text(encoding="utf-8"))
    return {"pending_codes": {}, "verified": {}}

def save_data():
    DATA_PATH.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")

data = load_data()

# Статусы серверов
server_status = {
    "servers": {},
    "last_update": None
}

STALE_TIMEOUT = 120
CODE_EXPIRY = 600  # 10 минут на ввод кода

# ========================
# Discord
# ========================

BOT_TOKEN = config.get("discord_bot_token", "")
STATUS_CHANNEL_ID = config.get("discord_channel_id", "")
VERIFY_CHANNEL_ID = config.get("discord_verify_channel_id", "")
VERIFIED_ROLE_ID = 1524819487256481880

intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)
tree = app_commands.CommandTree(client)
last_message_id = None


# ========================
# API: Статус серверов
# ========================

@app.post("/api/status")
def receive_status():
    req_data = request.get_json(silent=True)
    if not req_data or not req_data.get("ip"):
        return jsonify({"error": "Missing server IP"}), 400

    ip = req_data["ip"]
    server_status["servers"][ip] = {
        "ip": ip,
        "hostname": req_data.get("hostname", "Unknown"),
        "map": req_data.get("map", "unknown"),
        "players": req_data.get("players", 0),
        "maxPlayers": req_data.get("maxPlayers", 0),
        "gamemode": req_data.get("gamemode", "homigrad"),
        "timestamp": time.time()
    }
    server_status["last_update"] = time.time()
    print(f"[Status] {ip}: map={req_data.get('map')}, players={req_data.get('players')}/{req_data.get('maxPlayers')}")
    return jsonify({"ok": True})


@app.get("/api/status")
def get_status():
    now = time.time()
    active = [s for s in server_status["servers"].values() if now - s["timestamp"] < STALE_TIMEOUT]
    return jsonify({
        "servers": active,
        "game": config.get("game_name", "Homigrad"),
        "lastUpdate": server_status["last_update"]
    })


# ========================
# API: Верификация
# ========================

def generate_code():
    return "".join(random.choices(string.ascii_uppercase + string.digits, k=6))

def clean_expired_codes():
    now = time.time()
    expired = [k for k, v in data["pending_codes"].items() if now - v["created"] > CODE_EXPIRY]
    for k in expired:
        del data["pending_codes"][k]
    if expired:
        save_data()


@app.post("/api/verify/generate")
def verify_generate():
    """GMod запрашивает код верификации для игрока"""
    req_data = request.get_json(silent=True)
    if not req_data or not req_data.get("steamid"):
        return jsonify({"error": "Missing steamid"}), 400

    steamid = req_data["steamid"]

    # Проверяем, не верифицирован ли уже
    if steamid in data["verified"]:
        return jsonify({"error": "already_verified", "discord_id": data["verified"][steamid]["discord_id"]})

    # Удаляем старые коды
    clean_expired_codes()

    # Генерируем уникальный код
    code = generate_code()
    while code in data["pending_codes"]:
        code = generate_code()

    data["pending_codes"][code] = {
        "steamid": steamid,
        "created": time.time()
    }
    save_data()

    print(f"[Verify] Code generated for {steamid}: {code}")
    return jsonify({"ok": True, "code": code})


@app.post("/api/verify/check")
def verify_check():
    """GMod проверяет, верифицирован ли игрок"""
    req_data = request.get_json(silent=True)
    if not req_data or not req_data.get("steamid"):
        return jsonify({"error": "Missing steamid"}), 400

    steamid = req_data["steamid"]
    if steamid in data["verified"]:
        entry = data["verified"][steamid]
        return jsonify({"verified": True, "discord_id": entry["discord_id"]})

    return jsonify({"verified": False})


@app.post("/api/verify/unverify")
def verify_unverify():
    """GMod просит отвязать аккаунт"""
    req_data = request.get_json(silent=True)
    if not req_data or not req_data.get("steamid"):
        return jsonify({"error": "Missing steamid"}), 400

    steamid = req_data["steamid"]
    if steamid in data["verified"]:
        del data["verified"][steamid]
        save_data()
        print(f"[Verify] Unverified {steamid}")
        return jsonify({"ok": True})

    return jsonify({"error": "not_verified"})


# ========================
# Discord: Embed статус
# ========================

def build_embed():
    now = time.time()
    active = [s for s in server_status["servers"].values() if now - s["timestamp"] < STALE_TIMEOUT]
    if not active:
        return None

    total_players = sum(s.get("players", 0) for s in active)
    total_max = sum(s.get("maxPlayers", 0) for s in active)

    embed = discord.Embed(
        title=f"{config.get('game_name', 'Homigrad')} — Статус серверов",
        color=0x5865F2,
        timestamp=discord.utils.utcnow()
    )

    for s in active:
        name = s.get("hostname") or s["ip"]
        value = f"Карта: **{s['map']}** | Игроки: **{s['players']}/{s['maxPlayers']}**"
        embed.add_field(name=name, value=value, inline=False)

    embed.set_footer(text=f"Всего игроков: {total_players}/{total_max} | Серверов: {len(active)}")
    return embed


async def send_discord_update():
    global last_message_id
    if not client.is_ready():
        return

    channel = client.get_channel(int(STATUS_CHANNEL_ID))
    if not channel:
        return

    embed = build_embed()
    if not embed:
        return

    try:
        if last_message_id:
            try:
                msg = await channel.fetch_message(last_message_id)
                await msg.edit(embed=embed)
                print("[Discord] Status message edited")
                return
            except discord.NotFound:
                last_message_id = None

        msg = await channel.send(embed=embed)
        last_message_id = msg.id
        print("[Discord] Status message sent")
    except Exception as e:
        print(f"[Discord] Error: {e}")


# ========================
# Discord: Verify channel
# ========================

async def handle_verify_message(message):
    content = message.content.strip()
    channel_id = str(message.channel.id)

    # Реагируем только на команды в канале верификации
    if channel_id == VERIFY_CHANNEL_ID:
        reply = None
        code = content.upper()

        # Код напрямую (6 символов alphanumeric)
        if len(code) == 6 and code in data["pending_codes"]:
            entry = data["pending_codes"][code]
            steamid = entry["steamid"]

            # Сразу удаляем сообщение пользователя
            try:
                await message.delete()
            except Exception:
                pass

            # Связываем
            data["verified"][steamid] = {
                "discord_id": str(message.author.id),
                "discord_name": str(message.author),
                "verified_at": time.time()
            }
            del data["pending_codes"][code]
            save_data()

            # Выдаём роль Verified
            role = message.guild.get_role(VERIFIED_ROLE_ID)
            if role and role not in message.author.roles:
                try:
                    await message.author.add_roles(role)
                except Exception as e:
                    print(f"[Verify] Role error: {e}")

            reply = await message.channel.send(
                f"https://steamcommunity.com/profiles/{steamid}\n"
                f"`{steamid}`"
            )
            print(f"[Verify] Linked {steamid} ↔ {message.author} ({message.author.id})")
            await _schedule_delete(reply)
            return

        # !unverify_discord
        elif content.lower() == "!unverify_discord":
            try:
                await message.delete()
            except Exception:
                pass

            discord_id = str(message.author.id)
            found_steam = None
            for steamid, entry in data["verified"].items():
                if entry["discord_id"] == discord_id:
                    found_steam = steamid
                    break

            if found_steam:
                del data["verified"][found_steam]
                save_data()

                # Убираем роль Verified
                role = message.guild.get_role(VERIFIED_ROLE_ID)
                if role and role in message.author.roles:
                    try:
                        await message.author.remove_roles(role)
                    except Exception as e:
                        print(f"[Verify] Role remove error: {e}")

                reply = await message.channel.send(f"✅ Аккаунт отвязан. Steam: `{found_steam}`")
                print(f"[Verify] Unverified {found_steam} (Discord: {message.author})")
            else:
                reply = await message.channel.send("❌ Ваш Discord аккаунт не привязан к Steam.")
            await _schedule_delete(reply)
            return

        # !getsteam
        elif content.lower() == "!getsteam":
            try:
                await message.delete()
            except Exception:
                pass

            discord_id = str(message.author.id)
            found_steam = None
            for steamid, entry in data["verified"].items():
                if entry["discord_id"] == discord_id:
                    found_steam = steamid
                    break

            if found_steam:
                reply = await message.channel.send(
                    f"https://steamcommunity.com/profiles/{found_steam}\n"
                    f"`{found_steam}`"
                )
            else:
                reply = await message.channel.send("❌ Ваш Discord аккаунт не привязан к Steam.")
            await _schedule_delete(reply)
            return


async def _schedule_delete(*messages):
    """Удалить сообщения через 4 секунды"""
    await asyncio.sleep(4)
    for msg in messages:
        if msg is None:
            continue
        try:
            await msg.delete()
        except Exception:
            pass


# ========================
# Slash команды (ephemeral — видно только пользователю)
# ========================

@tree.command(name="verify", description="Привязать Steam аккаунт")
@app_commands.describe(code="Код из игры")
async def slash_verify(interaction: discord.Interaction, code: str):
    code = code.strip().upper()
    if code not in data["pending_codes"]:
        await interaction.response.send_message("❌ Неверный или просроченный код.", ephemeral=True)
        return

    entry = data["pending_codes"][code]
    steamid = entry["steamid"]

    data["verified"][steamid] = {
        "discord_id": str(interaction.user.id),
        "discord_name": str(interaction.user),
        "verified_at": time.time()
    }
    del data["pending_codes"][code]
    save_data()

    role = interaction.guild.get_role(VERIFIED_ROLE_ID)
    if role and role not in interaction.user.roles:
        try:
            await interaction.user.add_roles(role)
        except Exception as e:
            print(f"[Verify] Role error: {e}")

    await interaction.response.send_message(
        f"https://steamcommunity.com/profiles/{steamid}\n`{steamid}`",
        ephemeral=True
    )
    print(f"[Verify] Linked {steamid} ↔ {interaction.user} ({interaction.user.id})")


@tree.command(name="unverify", description="Отвязать Steam аккаунт")
async def slash_unverify(interaction: discord.Interaction):
    discord_id = str(interaction.user.id)
    found_steam = None
    for steamid, entry in data["verified"].items():
        if entry["discord_id"] == discord_id:
            found_steam = steamid
            break

    if found_steam:
        del data["verified"][found_steam]
        save_data()
        role = interaction.guild.get_role(VERIFIED_ROLE_ID)
        if role and role in interaction.user.roles:
            try:
                await interaction.user.remove_roles(role)
            except Exception as e:
                print(f"[Verify] Role remove error: {e}")
        await interaction.response.send_message(f"✅ Аккаунт отвязан. Steam: `{found_steam}`", ephemeral=True)
        print(f"[Verify] Unverified {found_steam} (Discord: {interaction.user})")
    else:
        await interaction.response.send_message("❌ Ваш Discord аккаунт не привязан к Steam.", ephemeral=True)


@tree.command(name="getsteam", description="Показать ваш Steam профиль")
async def slash_getsteam(interaction: discord.Interaction):
    discord_id = str(interaction.user.id)
    found_steam = None
    for steamid, entry in data["verified"].items():
        if entry["discord_id"] == discord_id:
            found_steam = steamid
            break

    if found_steam:
        await interaction.response.send_message(
            f"https://steamcommunity.com/profiles/{found_steam}\n`{found_steam}`",
            ephemeral=True
        )
    else:
        await interaction.response.send_message("❌ Ваш Discord аккаунт не привязан к Steam.", ephemeral=True)


# ========================
# Discord events
# ========================

@client.event
async def on_ready():
    print(f"[Discord] Bot connected as {client.user}")

    # Синхронизация slash команд
    await tree.sync()
    print("[Discord] Slash commands synced")

    # Отправляем инфо-сообщение в канал верификации
    if VERIFY_CHANNEL_ID:
        verify_ch = client.get_channel(int(VERIFY_CHANNEL_ID))
        if verify_ch:
            # Проверяем последние сообщения, не отправлять дубликат
            async for msg in verify_ch.history(limit=5):
                if msg.author == client.user and "привязать" in (msg.content or "").lower():
                    break
            else:
                await verify_ch.send(
                    "Что-бы привязать ваш Discord профиль с вашим Steam аккаунтом, вам нужно зайти на любой НАШ gmod сервер KOPIGRADCOM, и написать в чат !verify_discord, после чего ввести /verify код сюда. Если же хотите отвязать пишите /unverify"
                )

    # Статус серверов
    interval = config.get("update_interval", 30000) / 1000
    while True:
        await asyncio.sleep(interval)
        await send_discord_update()


@client.event
async def on_message(message):
    if message.author == client.user:
        return
    await handle_verify_message(message)


# ========================
# Файловый IPC (GMod <-> Backend)
# ========================

import os

# Путь к GMod data/ папке
# server.py -> backend/ -> hg_discord/ -> addons/ -> garrysmod/data/
GMOD_DATA = Path(__file__).parent.parent.parent.parent / "data"
IPC_REQ = GMOD_DATA / "hg_discord_ipc" / "req"
IPC_RES = GMOD_DATA / "hg_discord_ipc" / "res"

def ipc_write_response(req_id, result):
    """Записать ответ для GMod"""
    IPC_RES.mkdir(parents=True, exist_ok=True)
    path = IPC_RES / f"{req_id}.json"
    path.write_text(json.dumps(result, ensure_ascii=False), encoding="utf-8")

def ipc_process_request(req):
    """Обработать запрос от GMod"""
    method = req.get("method", "")
    body = req.get("body", {})
    req_id = req.get("id", "")

    if method == "status":
        ip = body.get("ip", "unknown")
        server_status["servers"][ip] = {
            "ip": ip,
            "hostname": body.get("hostname", "Unknown"),
            "map": body.get("map", "unknown"),
            "players": body.get("players", 0),
            "maxPlayers": body.get("maxPlayers", 0),
            "gamemode": body.get("gamemode", "homigrad"),
            "timestamp": time.time()
        }
        server_status["last_update"] = time.time()
        print(f"[IPC Status] {ip}: map={body.get('map')}, players={body.get('players')}/{body.get('maxPlayers')}")
        ipc_write_response(req_id, {"ok": True})

    elif method == "verify_generate":
        steamid = body.get("steamid", "")
        if not steamid:
            ipc_write_response(req_id, {"ok": False, "error": "missing steamid"})
            return

        if steamid in data["verified"]:
            ipc_write_response(req_id, {"ok": False, "error": "already_verified", "discord_id": data["verified"][steamid]["discord_id"]})
            return

        clean_expired_codes()
        code = generate_code()
        while code in data["pending_codes"]:
            code = generate_code()

        data["pending_codes"][code] = {"steamid": steamid, "created": time.time()}
        save_data()
        print(f"[IPC Verify] Code for {steamid}: {code}")
        ipc_write_response(req_id, {"ok": True, "code": code})

    elif method == "verify_unverify":
        steamid = body.get("steamid", "")
        if steamid in data["verified"]:
            del data["verified"][steamid]
            save_data()
            print(f"[IPC Verify] Unverified {steamid}")
            ipc_write_response(req_id, {"ok": True})
        else:
            ipc_write_response(req_id, {"ok": False, "error": "not_verified"})

    else:
        ipc_write_response(req_id, {"ok": False, "error": f"unknown method: {method}"})

def ipc_watcher():
    """Поллинг запросов от GMod"""
    print(f"[IPC] Watching: {IPC_REQ}")
    print(f"[IPC] GMod data dir: {GMOD_DATA}")
    IPC_REQ.mkdir(parents=True, exist_ok=True)
    IPC_RES.mkdir(parents=True, exist_ok=True)

    while True:
        try:
            for f in IPC_REQ.glob("*.json"):
                try:
                    raw = f.read_text(encoding="utf-8")
                    req = json.loads(raw)
                    ipc_process_request(req)
                except Exception as e:
                    print(f"[IPC] Error processing {f.name}: {e}")
                finally:
                    try:
                        f.unlink()
                    except Exception:
                        pass
        except Exception as e:
            print(f"[IPC] Watcher error: {e}")
        time.sleep(0.5)


# ========================
# Запуск
# ========================

def discord_loop():
    asyncio.run(client.start(BOT_TOKEN))


if __name__ == "__main__":
    port = config.get("port", 3567)
    print(f"[HG Discord] Backend running on port {port}")
    print(f"[HG Discord] File IPC: {IPC_REQ}")

    # Discord bot
    t = threading.Thread(target=discord_loop, daemon=True)
    t.start()

    # Файловый IPC watcher
    t2 = threading.Thread(target=ipc_watcher, daemon=True)
    t2.start()

    app.run(host="0.0.0.0", port=port)
