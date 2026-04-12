#!/usr/bin/env bash
# Carbon Fiber — single source of truth for all tool configs
# Usage: source this file, then reference $CF_* variables

# Backgrounds
export CF_BG="121214"
export CF_SURFACE="1a1a1c"
export CF_OVERLAY="232325"
export CF_BORDER="2a2a2c"

# Text hierarchy
export CF_DIM="444446"
export CF_MUTED="6a6a6c"
export CF_TEXT="909090"
export CF_BRIGHT="d0d0d0"
export CF_WHITE="e8e8e8"

# Semantic colors
export CF_ACCENT="e05030"
export CF_GREEN="80b080"
export CF_YELLOW="c8b060"
export CF_BLUE="808898"
export CF_RED="d04040"
export CF_CYAN="70b8b8"

# SketchyBar uses 0xAARRGGBB format
export CF_SKB_BG="0xff${CF_BG}"
export CF_SKB_SURFACE="0xff${CF_SURFACE}"
export CF_SKB_OVERLAY="0xff${CF_OVERLAY}"
export CF_SKB_BORDER="0xff${CF_BORDER}"
export CF_SKB_DIM="0xff${CF_DIM}"
export CF_SKB_MUTED="0xff${CF_MUTED}"
export CF_SKB_TEXT="0xff${CF_TEXT}"
export CF_SKB_BRIGHT="0xff${CF_BRIGHT}"
export CF_SKB_WHITE="0xff${CF_WHITE}"
export CF_SKB_ACCENT="0xff${CF_ACCENT}"
export CF_SKB_GREEN="0xff${CF_GREEN}"
export CF_SKB_YELLOW="0xff${CF_YELLOW}"
export CF_SKB_BLUE="0xff${CF_BLUE}"
export CF_SKB_RED="0xff${CF_RED}"
export CF_SKB_CYAN="0xff${CF_CYAN}"
export CF_SKB_ACCENT_DIM="0x1e${CF_ACCENT}"
