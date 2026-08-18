/* OpenIDE Web - Frontend Logic (Darcula/IntelliJ style) */

// === State ===
const state = {
    openTabs: [],
    activeTab: null,
    editor: null,
    contextTarget: null,
};

// === API ===
const api = {
    async listFiles(path = "") {
        const res = await fetch(`/api/files?path=${encodeURIComponent(path)}`);
        return res.json();
    },
    async readFile(path) {
        const res = await fetch(`/api/file?path=${encodeURIComponent(path)}`);
        return res.json();
    },
    async saveFile(path, content) {
        const res = await fetch("/api/file/save", {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({path, content})
        });
        return res.json();
    },
    async createFile(path, isDir = false) {
        const res = await fetch("/api/file/create", {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({path, isDir})
        });
        return res.json();
    },
    async deleteFile(path) {
        const res = await fetch("/api/file/delete", {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({path})
        });
        return res.json();
    },
    async renameFile(oldPath, newPath) {
        const res = await fetch("/api/file/rename", {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({oldPath, newPath})
        });
        return res.json();
    }
};

// === File Icons ===
function getFileIcon(name, isDir) {
    if (isDir) return "📁";
    const ext = name.split(".").pop().toLowerCase();
    const icons = {
        lua: "🌙", js: "🟨", ts: "🔷", py: "🐍", html: "🌐", css: "🎨",
        json: "📋", md: "📝", txt: "📄", xml: "📰", yml: "⚙️", yaml: "⚙️",
        sh: "🖥️", bat: "🖥️", sql: "🗃️", png: "🖼️", jpg: "🖼️", gif: "🖼️",
        svg: "🖼️", ogg: "🔊", wav: "🔊", mp3: "🔊", mdl: "🧊",
        zip: "📦", rar: "📦", cpp: "⚙️", c: "⚙️", java: "☕", kt: "🟣",
    };
    return icons[ext] || "📄";
}

// === Language Detection ===
function getLanguage(name) {
    const ext = name.split(".").pop().toLowerCase();
    const map = {
        lua: "lua", js: "javascript", ts: "typescript", py: "python",
        html: "html", css: "css", json: "json", xml: "xml", md: "markdown",
        sql: "sql", sh: "shell", bat: "bat", yml: "yaml", yaml: "yaml",
        cpp: "cpp", c: "c", h: "cpp", hpp: "cpp", java: "java",
        rs: "rust", go: "go", rb: "ruby", php: "php", kt: "kotlin",
    };
    return map[ext] || "plaintext";
}

// === File Tree ===
async function loadTree() {
    const tree = document.getElementById("file-tree");
    tree.innerHTML = "";
    const items = await api.listFiles("");
    if (items.error) { tree.innerHTML = `<div style="padding:10px;color:#f55">${items.error}</div>`; return; }
    renderTreeItems(tree, items, "");
}

function renderTreeItems(container, items, parentPath) {
    items.forEach(item => {
        const row = document.createElement("div");
        const itemEl = document.createElement("div");
        itemEl.className = "tree-item";
        itemEl.dataset.path = item.path;
        itemEl.dataset.isDir = item.isDir;

        const arrow = document.createElement("span");
        arrow.className = "arrow";
        arrow.textContent = item.isDir ? "▶" : "";
        itemEl.appendChild(arrow);

        const icon = document.createElement("span");
        icon.className = "icon";
        icon.textContent = getFileIcon(item.name, item.isDir);
        itemEl.appendChild(icon);

        const name = document.createElement("span");
        name.className = "name";
        name.textContent = item.name;
        itemEl.appendChild(name);

        itemEl.addEventListener("click", (e) => {
            e.stopPropagation();
            document.querySelectorAll(".tree-item.selected").forEach(el => el.classList.remove("selected"));
            if (item.isDir) {
                toggleFolder(itemEl, item);
            } else {
                itemEl.classList.add("selected");
                openFile(item.path, item.name);
            }
        });

        itemEl.addEventListener("contextmenu", (e) => {
            e.preventDefault();
            e.stopPropagation();
            showContextMenu(e.clientX, e.clientY, item);
        });

        row.appendChild(itemEl);

        if (item.isDir) {
            const children = document.createElement("div");
            children.className = "tree-children collapsed";
            children.dataset.path = item.path;
            row.appendChild(children);
        }

        container.appendChild(row);
    });
}

async function toggleFolder(itemEl, item) {
    const row = itemEl.parentElement;
    const children = row.querySelector(".tree-children");
    const arrow = itemEl.querySelector(".arrow");

    if (children.classList.contains("collapsed")) {
        if (children.children.length === 0) {
            const items = await api.listFiles(item.path);
            if (!items.error) renderTreeItems(children, items, item.path);
        }
        children.classList.remove("collapsed");
        arrow.classList.add("open");
    } else {
        children.classList.add("collapsed");
        arrow.classList.remove("open");
    }
}

// === File Opening & Tabs ===
async function openFile(path, name) {
    const existing = state.openTabs.find(t => t.path === path);
    if (existing) { activateTab(path); return; }

    const data = await api.readFile(path);
    if (data.error) return;

    const model = monaco.editor.createModel(data.content, getLanguage(name));
    const tab = { path, name, content: data.content, modified: false, model };
    state.openTabs.push(tab);
    renderTabs();
    activateTab(path);
}

function activateTab(path) {
    if (state.activeTab && state.editor) {
        const current = state.openTabs.find(t => t.path === state.activeTab);
        if (current) current.content = state.editor.getValue();
    }

    state.activeTab = path;
    const tab = state.openTabs.find(t => t.path === path);
    if (!tab) return;

    state.editor.setModel(tab.model);
    document.getElementById("status-path").textContent = tab.path;
    document.getElementById("status-lang").textContent = getLanguage(tab.name).toUpperCase();
    document.getElementById("toolbar-path").textContent = tab.path;
    renderTabs();
}

function closeTab(path, e) {
    if (e) e.stopPropagation();
    const idx = state.openTabs.findIndex(t => t.path === path);
    if (idx === -1) return;

    const tab = state.openTabs[idx];
    if (tab.modified && !confirm(`${tab.name} has unsaved changes. Close anyway?`)) return;

    tab.model.dispose();
    state.openTabs.splice(idx, 1);

    if (state.activeTab === path) {
        if (state.openTabs.length > 0) {
            activateTab(state.openTabs[Math.min(idx, state.openTabs.length - 1)].path);
        } else {
            state.activeTab = null;
            state.editor.setModel(monaco.editor.createModel("", "plaintext"));
            document.getElementById("status-path").textContent = "";
            document.getElementById("status-lang").textContent = "";
            document.getElementById("toolbar-path").textContent = "";
        }
    }
    renderTabs();
}

function renderTabs() {
    const tabsEl = document.getElementById("tabs");
    tabsEl.innerHTML = "";
    state.openTabs.forEach(tab => {
        const tabEl = document.createElement("div");
        tabEl.className = "tab" + (tab.path === state.activeTab ? " active" : "") + (tab.modified ? " modified" : "");

        const icon = document.createElement("span");
        icon.style.marginRight = "5px";
        icon.style.fontSize = "11px";
        icon.textContent = getFileIcon(tab.name, false);

        const nameEl = document.createElement("span");
        nameEl.className = "tab-name";
        nameEl.textContent = tab.name;

        const closeEl = document.createElement("span");
        closeEl.className = "tab-close";
        closeEl.textContent = "×";
        closeEl.addEventListener("click", (e) => closeTab(tab.path, e));

        tabEl.appendChild(icon);
        tabEl.appendChild(nameEl);
        tabEl.appendChild(closeEl);
        tabEl.addEventListener("click", () => activateTab(tab.path));
        tabsEl.appendChild(tabEl);
    });
}

// === Save ===
async function saveCurrentFile() {
    if (!state.activeTab) return;
    const tab = state.openTabs.find(t => t.path === state.activeTab);
    if (!tab) return;

    const content = state.editor.getValue();
    const result = await api.saveFile(tab.path, content);

    if (result.ok) {
        tab.content = content;
        tab.modified = false;
        renderTabs();
        showStatus("Saved: " + tab.name);
    } else {
        showStatus("Error: " + result.error);
    }
}

function showStatus(msg) {
    const el = document.getElementById("status-path");
    el.textContent = msg;
    setTimeout(() => {
        if (state.activeTab) {
            const tab = state.openTabs.find(t => t.path === state.activeTab);
            el.textContent = tab ? tab.path : "";
        }
    }, 2000);
}

// === Context Menu ===
function showContextMenu(x, y, item) {
    state.contextTarget = item;
    const menu = document.getElementById("context-menu");
    menu.classList.remove("hidden");
    menu.style.left = x + "px";
    menu.style.top = y + "px";
}

function hideContextMenu() {
    document.getElementById("context-menu").classList.add("hidden");
}

document.getElementById("context-menu").addEventListener("click", async (e) => {
    const action = e.target.dataset.action;
    if (!action || !state.contextTarget) return;
    const target = state.contextTarget;
    hideContextMenu();

    switch (action) {
        case "new-file": await promptCreate(target.path, false); break;
        case "new-folder": await promptCreate(target.path, true); break;
        case "rename": await promptRename(target); break;
        case "delete":
            if (confirm(`Delete "${target.name}"?`)) {
                await api.deleteFile(target.path);
                loadTree();
                const openTab = state.openTabs.find(t => t.path === target.path);
                if (openTab) closeTab(target.path);
            }
            break;
    }
});

document.addEventListener("click", (e) => {
    hideContextMenu();
    hideDropdown();
});

// === Dropdown Menus ===
const menuData = {
    file: [
        { label: "New File", shortcut: "Ctrl+N", action: () => promptCreate("", false) },
        { label: "New Folder", action: () => promptCreate("", true) },
        { sep: true },
        { label: "Save", shortcut: "Ctrl+S", action: saveCurrentFile },
        { label: "Save All", shortcut: "Ctrl+Shift+S", action: saveAll },
        { sep: true },
        { label: "Close Tab", shortcut: "Ctrl+W", action: () => state.activeTab && closeTab(state.activeTab) },
    ],
    edit: [
        { label: "Undo", shortcut: "Ctrl+Z", action: () => state.editor?.trigger("keyboard", "undo") },
        { label: "Redo", shortcut: "Ctrl+Y", action: () => state.editor?.trigger("keyboard", "redo") },
        { sep: true },
        { label: "Find", shortcut: "Ctrl+F", action: () => state.editor?.trigger("keyboard", "actions.find") },
        { label: "Replace", shortcut: "Ctrl+H", action: () => state.editor?.trigger("keyboard", "editor.action.startFindReplaceAction") },
    ],
    view: [
        { label: "Toggle Sidebar", action: toggleSidebar },
        { label: "Toggle Bottom Panel", action: toggleBottomPanel },
    ],
    navigate: [
        { label: "Go to File", shortcut: "Ctrl+Shift+N", action: () => {} },
        { label: "Go to Line", shortcut: "Ctrl+G", action: () => state.editor?.trigger("keyboard", "editor.action.gotoLine") },
    ],
    code: [
        { label: "Format Document", shortcut: "Ctrl+Alt+L", action: () => state.editor?.trigger("keyboard", "editor.action.formatDocument") },
        { label: "Toggle Comment", shortcut: "Ctrl+/", action: () => state.editor?.trigger("keyboard", "editor.action.commentLine") },
    ],
};

function showDropdown(menuName, x, y) {
    const dd = document.getElementById("dropdown-menu");
    const items = menuData[menuName];
    if (!items) return;

    dd.innerHTML = "";
    items.forEach(item => {
        if (item.sep) {
            const sep = document.createElement("div");
            sep.className = "dd-sep";
            dd.appendChild(sep);
        } else {
            const el = document.createElement("div");
            el.className = "dd-item";
            el.innerHTML = `<span>${item.label}</span>${item.shortcut ? `<span class="shortcut">${item.shortcut}</span>` : ""}`;
            el.addEventListener("click", (e) => { e.stopPropagation(); hideDropdown(); item.action(); });
            dd.appendChild(el);
        }
    });

    dd.classList.remove("hidden");
    dd.style.left = x + "px";
    dd.style.top = y + "px";
}

function hideDropdown() {
    document.getElementById("dropdown-menu").classList.add("hidden");
}

// Menu bar click handlers
document.querySelectorAll(".menu-item").forEach(el => {
    el.addEventListener("click", (e) => {
        e.stopPropagation();
        const rect = el.getBoundingClientRect();
        showDropdown(el.dataset.menu, rect.left, rect.bottom);
    });
});

// === Dialogs ===
function showDialog(title, defaultValue = "") {
    return new Promise((resolve) => {
        const overlay = document.createElement("div");
        overlay.className = "dialog-overlay";
        overlay.innerHTML = `
            <div class="dialog">
                <h3>${title}</h3>
                <input type="text" value="${defaultValue}" id="dialog-input">
                <div class="dialog-buttons">
                    <button class="btn-cancel">Cancel</button>
                    <button class="btn-ok">OK</button>
                </div>
            </div>
        `;
        document.body.appendChild(overlay);
        const input = overlay.querySelector("#dialog-input");
        input.focus(); input.select();
        const close = (val) => { overlay.remove(); resolve(val); };
        overlay.querySelector(".btn-ok").addEventListener("click", () => close(input.value.trim()));
        overlay.querySelector(".btn-cancel").addEventListener("click", () => close(null));
        input.addEventListener("keydown", (e) => {
            if (e.key === "Enter") close(input.value.trim());
            if (e.key === "Escape") close(null);
        });
        overlay.addEventListener("click", (e) => { if (e.target === overlay) close(null); });
    });
}

async function promptCreate(parentPath, isDir) {
    const basePath = parentPath || "";
    const name = await showDialog(isDir ? "New Folder" : "New File", "");
    if (!name) return;
    const fullPath = basePath ? `${basePath}/${name}` : name;
    await api.createFile(fullPath, isDir);
    loadTree();
}

async function promptRename(target) {
    const newName = await showDialog("Rename", target.name);
    if (!newName || newName === target.name) return;
    const parentPath = target.path.includes("/") ? target.path.substring(0, target.path.lastIndexOf("/")) : "";
    const newPath = parentPath ? `${parentPath}/${newName}` : newName;
    await api.renameFile(target.path, newPath);
    const tab = state.openTabs.find(t => t.path === target.path);
    if (tab) { tab.path = newPath; tab.name = newName; renderTabs(); }
    loadTree();
}

async function saveAll() {
    for (const tab of state.openTabs) {
        if (tab.modified) {
            const content = tab.path === state.activeTab ? state.editor.getValue() : tab.content;
            await api.saveFile(tab.path, content);
            tab.content = content;
            tab.modified = false;
        }
    }
    renderTabs();
}

// === Panel Toggles ===
function toggleSidebar() {
    const panel = document.getElementById("left-panel");
    const strip = document.getElementById("left-strip");
    panel.classList.toggle("hidden");
    strip.classList.toggle("hidden");
}

function toggleBottomPanel() {
    const area = document.getElementById("bottom-area");
    area.classList.toggle("hidden");
}

// === Resize Handles ===
function initResize(handleId, panel, direction) {
    const handle = document.getElementById(handleId);
    let startX, startWidth;
    handle.addEventListener("mousedown", (e) => {
        startX = e.clientX;
        startWidth = panel.offsetWidth;
        document.addEventListener("mousemove", onResize);
        document.addEventListener("mouseup", stopResize);
        e.preventDefault();
    });
    function onResize(e) {
        const diff = direction === "left" ? e.clientX - startX : startX - e.clientX;
        const newWidth = startWidth + diff;
        if (newWidth >= 150 && newWidth <= 600) panel.style.width = newWidth + "px";
    }
    function stopResize() {
        document.removeEventListener("mousemove", onResize);
        document.removeEventListener("mouseup", stopResize);
    }
}
initResize("resize-left", document.getElementById("left-panel"), "left");

// === Toolbar Buttons ===
document.getElementById("btn-save").addEventListener("click", saveCurrentFile);
document.getElementById("btn-new-file").addEventListener("click", () => promptCreate("", false));
document.getElementById("btn-new-file2").addEventListener("click", () => promptCreate("", false));
document.getElementById("btn-new-folder").addEventListener("click", () => promptCreate("", true));

// === Keyboard Shortcuts ===
document.addEventListener("keydown", (e) => {
    if (e.ctrlKey && e.key === "s") { e.preventDefault(); saveCurrentFile(); }
    if (e.ctrlKey && e.key === "w") { e.preventDefault(); if (state.activeTab) closeTab(state.activeTab); }
    if (e.ctrlKey && e.key === "n") { e.preventDefault(); promptCreate("", false); }
});

// === Monaco Editor Init ===
require.config({paths: {vs: "https://cdn.jsdelivr.net/npm/monaco-editor@0.45.0/min/vs"}});

require(["vs/editor/editor.main"], function () {
    monaco.editor.defineTheme("darcula", {
        base: "vs-dark",
        inherit: true,
        rules: [
            { token: "comment", foreground: "808080", fontStyle: "italic" },
            { token: "keyword", foreground: "CC7832" },
            { token: "string", foreground: "6A8759" },
            { token: "number", foreground: "6897BB" },
            { token: "type", foreground: "A9B7C6" },
            { token: "identifier", foreground: "A9B7C6" },
            { token: "delimiter", foreground: "A9B7C6" },
        ],
        colors: {
            "editor.background": "#2B2B2B",
            "editor.foreground": "#A9B7C6",
            "editor.lineHighlightBackground": "#323232",
            "editor.selectionBackground": "#214283",
            "editor.inactiveSelectionBackground": "#344134",
            "editorCursor.foreground": "#BBBBBB",
            "editorLineNumber.foreground": "#606366",
            "editorLineNumber.activeForeground": "#A4A3A3",
            "editor.selectionHighlightBackground": "#344134",
            "editorIndentGuide.background": "#373737",
            "editorIndentGuide.activeBackground": "#555555",
        }
    });

    state.editor = monaco.editor.create(document.getElementById("editor-container"), {
        value: "",
        language: "plaintext",
        theme: "darcula",
        fontSize: 13,
        fontFamily: "'JetBrains Mono', 'Cascadia Code', 'Fira Code', 'Consolas', monospace",
        fontLigatures: true,
        minimap: { enabled: true },
        automaticLayout: true,
        scrollBeyondLastLine: false,
        wordWrap: "off",
        lineNumbers: "on",
        renderWhitespace: "selection",
        bracketPairColorization: { enabled: true },
        padding: { top: 6 },
        renderLineHighlight: "all",
    });

    // Track cursor position
    state.editor.onDidChangeCursorPosition((e) => {
        document.getElementById("status-pos").textContent = `Ln ${e.position.lineNumber}, Col ${e.position.column}`;
    });

    // Track modifications
    state.editor.onDidChangeModelContent(() => {
        if (!state.activeTab) return;
        const tab = state.openTabs.find(t => t.path === state.activeTab);
        if (tab && !tab.modified) { tab.modified = true; renderTabs(); }
    });

    loadTree();
});
