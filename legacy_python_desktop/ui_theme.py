"""
Theme and styling definitions for Interview Prep TTS Repeater App.
"""

DARK_THEME = {
    "bg_app": "#1a1b26",
    "bg_sidebar": "#16161e",
    "bg_card": "#24283b",
    "bg_card_hover": "#2f354f",
    "bg_card_active": "#3b4261",
    "bg_header": "#1f2335",
    "bg_input": "#1a1b26",
    
    "primary": "#7aa2f7",
    "primary_hover": "#89b4fa",
    "secondary": "#2ac3de",
    "accent_purple": "#bb9af7",
    
    "text_main": "#c0caf5",
    "text_secondary": "#a9b1d6",
    "text_muted": "#565f89",
    "text_bright": "#ffffff",
    
    "status_mastered": "#9ece6a",
    "status_needs_practice": "#e0af68",
    "status_unread": "#7dcfff",
    "star_active": "#e0af68",
    "star_inactive": "#565f89",
    
    "border": "#292e42",
    "active_indicator": "#7aa2f7"
}

LIGHT_THEME = {
    "bg_app": "#f4f6fb",
    "bg_sidebar": "#ffffff",
    "bg_card": "#ffffff",
    "bg_card_hover": "#f0f3f9",
    "bg_card_active": "#e2e8f5",
    "bg_header": "#ffffff",
    "bg_input": "#f0f3f9",
    
    "primary": "#2563eb",
    "primary_hover": "#1d4ed8",
    "secondary": "#0891b2",
    "accent_purple": "#7c3aed",
    
    "text_main": "#0f172a",
    "text_secondary": "#475569",
    "text_muted": "#94a3b8",
    "text_bright": "#ffffff",
    
    "status_mastered": "#16a34a",
    "status_needs_practice": "#d97706",
    "status_unread": "#0284c7",
    "star_active": "#d97706",
    "star_inactive": "#cbd5e1",
    
    "border": "#e2e8f0",
    "active_indicator": "#2563eb"
}

STATUS_BADGES = {
    "mastered": {"label": "✓ Mastered", "color_dark": "#9ece6a", "color_light": "#16a34a"},
    "needs_practice": {"label": "⚡ Practice", "color_dark": "#e0af68", "color_light": "#d97706"},
    "unread": {"label": "● Unread", "color_dark": "#7dcfff", "color_light": "#0284c7"}
}

CATEGORY_ICONS = {
    "General": "📌",
    "HR": "👥",
    "Technical": "💻",
    "Behavioral": "🧠",
    "System Design": "🏗️",
    "Python": "🐍",
    "Web Development": "🌐",
    "Data Structures & Algorithms": "⚡"
}

def get_category_icon(cat):
    return CATEGORY_ICONS.get(cat, "📁")
