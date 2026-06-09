#!/usr/bin/env bash
set -euo pipefail

TARGET_MONITOR="${TARGET_MONITOR:-HDMI-A-1}"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr-big-monitor-toggle"

require_cmd() {
	local cmd="$1"

	if ! command -v "$cmd" >/dev/null 2>&1; then
		hyprctl notify -1 5000 "rgb(ff5555)" "Missing command: $cmd" >/dev/null 2>&1 || true
		exit 1
	fi
}

active_window() {
	hyprctl -j activewindow
}

window_state_file() {
	local address="$1"

	printf '%s/%s.json\n' "$STATE_DIR" "${address#0x}"
}

require_cmd hyprctl
require_cmd jq

window_json="$(active_window)"
address="$(jq -r '.address // empty' <<<"$window_json")"

if [[ -z "$address" || "$address" == "0x0" ]]; then
	exit 0
fi

mkdir -p "$STATE_DIR"
state_file="$(window_state_file "$address")"

if [[ -f "$state_file" ]]; then
	saved_workspace="$(jq -r '.workspace_id' "$state_file")"
	saved_floating="$(jq -r '.floating' "$state_file")"

	hyprctl dispatch fullscreenstate 0 0 >/dev/null
	hyprctl dispatch movetoworkspace "$saved_workspace" >/dev/null

	current_floating="$(active_window | jq -r '.floating')"
	if [[ "$current_floating" != "$saved_floating" ]]; then
		hyprctl dispatch togglefloating >/dev/null
	fi

	rm -f "$state_file"
	exit 0
fi

jq '{
	address,
	workspace_id: .workspace.id,
	workspace_name: .workspace.name,
	monitor,
	floating,
	fullscreen,
	fullscreenClient
}' <<<"$window_json" >"$state_file"

hyprctl dispatch movewindow "mon:${TARGET_MONITOR}" >/dev/null
hyprctl dispatch fullscreenstate 1 1 >/dev/null
