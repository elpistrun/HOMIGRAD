"""
Web IDE Server - Python-based IDE backend
Run: python server.py
Open: http://localhost:8080
"""

import os
import json
import shutil
import mimetypes
import subprocess
import sys
from pathlib import Path
from aiohttp import web

# Root directory for file browsing (parent of ide folder)
WORKSPACE = Path(__file__).parent.parent
PORT = 8181

# --- File API ---

async def api_list_files(request):
    """List files and folders in a directory"""
    rel_path = request.query.get("path", "")
    target = (WORKSPACE / rel_path).resolve()
    
    # Security: stay within workspace
    if not str(target).startswith(str(WORKSPACE.resolve())):
        return web.json_response({"error": "Access denied"}, status=403)
    
    if not target.is_dir():
        return web.json_response({"error": "Not a directory"}, status=404)
    
    items = []
    try:
        for entry in sorted(target.iterdir(), key=lambda e: (not e.is_dir(), e.name.lower())):
            # Skip hidden and ide folder
            if entry.name.startswith("."):
                continue
            if entry.name == "ide" and entry.is_dir():
                continue
            
            stat = entry.stat()
            items.append({
                "name": entry.name,
                "path": str(entry.relative_to(WORKSPACE)),
                "isDir": entry.is_dir(),
                "size": stat.st_size if not entry.is_dir() else 0,
            })
    except PermissionError:
        return web.json_response({"error": "Permission denied"}, status=403)
    
    return web.json_response(items)


async def api_read_file(request):
    """Read file content"""
    rel_path = request.query.get("path", "")
    target = (WORKSPACE / rel_path).resolve()
    
    if not str(target).startswith(str(WORKSPACE.resolve())):
        return web.json_response({"error": "Access denied"}, status=403)
    
    if not target.is_file():
        return web.json_response({"error": "File not found"}, status=404)
    
    try:
        content = target.read_text(encoding="utf-8", errors="replace")
        return web.json_response({"content": content, "path": rel_path})
    except Exception as e:
        return web.json_response({"error": str(e)}, status=500)


async def api_save_file(request):
    """Save file content"""
    data = await request.json()
    rel_path = data.get("path", "")
    content = data.get("content", "")
    target = (WORKSPACE / rel_path).resolve()
    
    if not str(target).startswith(str(WORKSPACE.resolve())):
        return web.json_response({"error": "Access denied"}, status=403)
    
    try:
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")
        return web.json_response({"ok": True})
    except Exception as e:
        return web.json_response({"error": str(e)}, status=500)


async def api_create_file(request):
    """Create a new file or folder"""
    data = await request.json()
    rel_path = data.get("path", "")
    is_dir = data.get("isDir", False)
    target = (WORKSPACE / rel_path).resolve()
    
    if not str(target).startswith(str(WORKSPACE.resolve())):
        return web.json_response({"error": "Access denied"}, status=403)
    
    if target.exists():
        return web.json_response({"error": "Already exists"}, status=409)
    
    try:
        if is_dir:
            target.mkdir(parents=True, exist_ok=True)
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text("", encoding="utf-8")
        return web.json_response({"ok": True})
    except Exception as e:
        return web.json_response({"error": str(e)}, status=500)


async def api_delete_file(request):
    """Delete a file or folder"""
    data = await request.json()
    rel_path = data.get("path", "")
    target = (WORKSPACE / rel_path).resolve()
    
    if not str(target).startswith(str(WORKSPACE.resolve())):
        return web.json_response({"error": "Access denied"}, status=403)
    
    if not target.exists():
        return web.json_response({"error": "Not found"}, status=404)
    
    try:
        if target.is_dir():
            shutil.rmtree(target)
        else:
            target.unlink()
        return web.json_response({"ok": True})
    except Exception as e:
        return web.json_response({"error": str(e)}, status=500)


async def api_rename_file(request):
    """Rename/move a file or folder"""
    data = await request.json()
    old_path = data.get("oldPath", "")
    new_path = data.get("newPath", "")
    
    src = (WORKSPACE / old_path).resolve()
    dst = (WORKSPACE / new_path).resolve()
    
    for p in (src, dst):
        if not str(p).startswith(str(WORKSPACE.resolve())):
            return web.json_response({"error": "Access denied"}, status=403)
    
    if not src.exists():
        return web.json_response({"error": "Source not found"}, status=404)
    
    if dst.exists():
        return web.json_response({"error": "Destination already exists"}, status=409)
    
    try:
        dst.parent.mkdir(parents=True, exist_ok=True)
        src.rename(dst)
        return web.json_response({"ok": True})
    except Exception as e:
        return web.json_response({"error": str(e)}, status=500)


# --- Static files ---

async def handle_index(request):
    """Serve index.html"""
    return web.FileResponse(Path(__file__).parent / "static" / "index.html")


# --- App setup ---

app = web.Application()
app.router.add_get("/api/files", api_list_files)
app.router.add_get("/api/file", api_read_file)
app.router.add_post("/api/file/save", api_save_file)
app.router.add_post("/api/file/create", api_create_file)
app.router.add_post("/api/file/delete", api_delete_file)
app.router.add_post("/api/file/rename", api_rename_file)

# Serve static files
app.router.add_get("/", handle_index)
app.router.add_static("/static/", Path(__file__).parent / "static")

if __name__ == "__main__":
    print(f"IDE Server starting on http://localhost:{PORT}")
    print(f"Workspace: {WORKSPACE}")
    web.run_app(app, port=PORT, print=None)
