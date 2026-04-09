#!/home/flyingkuskus/.local/share/pipx/venvs/togglcli/bin/python3
"""DMS aw-status plugin — single JSON line describing AW tracking state.

Emits a single compact JSON object on stdout for the QML widget to parse:

    {
      "alive": true,
      "dead": [],
      "events_today": 348,
      "current": {"app": "kitty", "title": "Claude Code"},
      "top": [{"app": "kitty", "seconds": 1080}, ...]
    }

On failure always emits a valid object with "alive": false and an error
field so the widget can render an error pill instead of breaking.
"""
from __future__ import annotations

import json
import socket
import subprocess
import sys
import urllib.request
import urllib.error
from collections import Counter
from datetime import datetime, time as dtime, timezone, timedelta

AW_BASE = "http://localhost:5600/api/0"
SERVICES = ["aw-server.service", "aw-awatcher.service", "aw-watcher-git.service"]
HOST = socket.gethostname()
BUCKETS = [
    f"aw-watcher-window_{HOST}",
    f"aw-watcher-afk_{HOST}",
    f"aw-watcher-git_{HOST}",
    f"aw-watcher-web-chrome_{HOST}",
]
WINDOW_BUCKET = f"aw-watcher-window_{HOST}"


def service_status() -> tuple[bool, list[str]]:
    dead: list[str] = []
    for svc in SERVICES:
        try:
            r = subprocess.run(
                ["systemctl", "--user", "is-active", svc],
                capture_output=True,
                text=True,
                timeout=2,
            )
            if r.stdout.strip() != "active":
                dead.append(svc.replace(".service", ""))
        except (subprocess.TimeoutExpired, FileNotFoundError):
            dead.append(svc.replace(".service", ""))
    return (not dead, dead)


def aw_get(path: str, timeout: float = 2.0):
    try:
        with urllib.request.urlopen(f"{AW_BASE}{path}", timeout=timeout) as r:
            return json.load(r)
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError):
        return None


def iso_utc(dt: datetime) -> str:
    return dt.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def events_today_count() -> int:
    now_local = datetime.now().astimezone()
    midnight_local = datetime.combine(now_local.date(), dtime.min).astimezone()
    start = iso_utc(midnight_local)
    end = iso_utc(now_local + timedelta(seconds=60))
    total = 0
    for b in BUCKETS:
        evs = aw_get(f"/buckets/{b}/events?start={start}&end={end}&limit=10000")
        if evs is None:
            continue
        total += len(evs)
    return total


def current_window() -> dict | None:
    evs = aw_get(f"/buckets/{WINDOW_BUCKET}/events?limit=1")
    if not evs:
        return None
    data = evs[0].get("data", {})
    return {"app": data.get("app", "?"), "title": data.get("title", "")}


def top_apps_last_30min(n: int = 5) -> list[dict]:
    now = datetime.now(timezone.utc)
    start = iso_utc(now - timedelta(minutes=30))
    end = iso_utc(now + timedelta(seconds=60))
    evs = aw_get(
        f"/buckets/{WINDOW_BUCKET}/events?start={start}&end={end}&limit=10000"
    )
    if not evs:
        return []
    totals: Counter[str] = Counter()
    for e in evs:
        app = e.get("data", {}).get("app")
        dur = e.get("duration", 0)
        if app:
            totals[app] += dur
    return [{"app": a, "seconds": int(s)} for a, s in totals.most_common(n)]


def main() -> int:
    try:
        alive, dead = service_status()
        out = {
            "alive": alive,
            "dead": dead,
            "events_today": events_today_count(),
            "current": current_window(),
            "top": top_apps_last_30min(),
        }
    except Exception as e:  # noqa: BLE001
        out = {
            "alive": False,
            "dead": [],
            "events_today": 0,
            "current": None,
            "top": [],
            "error": f"{type(e).__name__}: {e}",
        }
    print(json.dumps(out))
    return 0


if __name__ == "__main__":
    sys.exit(main())
