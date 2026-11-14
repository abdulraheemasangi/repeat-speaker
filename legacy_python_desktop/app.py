import os
import sys
import tkinter as tk
from tkinter import filedialog, messagebox
import customtkinter as ctk

from database import DatabaseManager
from sample_data import populate_sample_data_if_empty
from tts_engine import TTSEngine
from ui_theme import DARK_THEME, LIGHT_THEME, STATUS_BADGES, get_category_icon

ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class InterviewPrepApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("Interview Prep - Text to Speech Repeater")
        self.geometry("1240x820")
        self.minsize(1050, 700)

        # Initialize Backend
        self.db = DatabaseManager()
        populate_sample_data_if_empty(self.db)
        self.tts = TTSEngine()

        # Wire TTS Callbacks
        self.tts.on_status_change = self._on_tts_status_change
        self.tts.on_item_changed = self._on_tts_item_changed
        self.tts.on_finished = self._on_tts_finished

        # App UI State
        self.current_theme = "Dark"
        self.selected_category = "All"
        self.selected_status = "All"
        self.search_query = ""
        self.playlist = []
        self.current_item_index = 0
        self.selected_item = None
        self.answer_revealed = True
        self.qa_card_widgets = []

        # Build GUI Layout
        self._setup_ui()

        # Bind Global Keyboard Shortcuts
        self._bind_keyboard_shortcuts()

        # Load initial data
        self.refresh_qa_list()

    # -------------------------------------------------------------
    # UI SETUP & LAYOUT
    # -------------------------------------------------------------
    def _setup_ui(self):
        # Main Grid Config (Header top, Body middle)
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(1, weight=1)

        # 1. TOP HEADER BAR
        self._create_header_bar()

        # 2. MAIN BODY AREA (Sidebar Left + Content Right)
        self.body_frame = ctk.CTkFrame(self, fg_color="transparent", corner_radius=0)
        self.body_frame.grid(row=1, column=0, sticky="nsew", padx=10, pady=(0, 10))
        self.body_frame.grid_columnconfigure(0, weight=0) # Sidebar fixed width
        self.body_frame.grid_columnconfigure(1, weight=1) # Main area expandable
        self.body_frame.grid_rowconfigure(0, weight=1)

        self._create_sidebar()
        self._create_main_content()

    def _create_header_bar(self):
        self.header_frame = ctk.CTkFrame(self, height=65, corner_radius=10)
        self.header_frame.grid(row=0, column=0, sticky="ew", padx=10, pady=10)
        self.header_frame.grid_columnconfigure(3, weight=1)

        # App Logo & Title
        title_label = ctk.CTkLabel(
            self.header_frame, 
            text="🎙️ Interview Prep TTS Repeater", 
            font=ctk.CTkFont(size=20, weight="bold")
        )
        title_label.grid(row=0, column=0, padx=15, pady=12)

        # Overall Progress Bar
        self.progress_frame = ctk.CTkFrame(self.header_frame, fg_color="transparent")
        self.progress_frame.grid(row=0, column=1, padx=10)

        self.progress_lbl = ctk.CTkLabel(
            self.progress_frame, 
            text="Mastered: 0%", 
            font=ctk.CTkFont(size=12, weight="bold")
        )
        self.progress_lbl.pack(anchor="w")

        self.progress_bar = ctk.CTkProgressBar(self.progress_frame, width=150, height=10)
        self.progress_bar.set(0.0)
        self.progress_bar.pack(pady=(2, 0))

        # Search Entry
        self.search_entry = ctk.CTkEntry(
            self.header_frame, 
            placeholder_text="🔍 Search questions or answers...",
            width=260
        )
        self.search_entry.grid(row=0, column=2, padx=15)
        self.search_entry.bind("<KeyRelease>", self._on_search_key_release)

        # Header Right Controls (+Add Q&A, Import/Export, Theme Toggle)
        btn_box = ctk.CTkFrame(self.header_frame, fg_color="transparent")
        btn_box.grid(row=0, column=3, sticky="e", padx=15)

        add_btn = ctk.CTkButton(
            btn_box, 
            text="+ Add Q&A", 
            font=ctk.CTkFont(weight="bold"), 
            fg_color="#2563eb", 
            hover_color="#1d4ed8",
            width=110,
            command=self.open_add_qa_modal
        )
        add_btn.pack(side="left", padx=5)

        imp_exp_btn = ctk.CTkOptionMenu(
            btn_box,
            values=["Import / Export", "📥 Import JSON", "📥 Import CSV", "📤 Export JSON", "📤 Export CSV"],
            command=self._handle_import_export_option,
            width=130
        )
        imp_exp_btn.pack(side="left", padx=5)

        self.theme_switch = ctk.CTkSwitch(
            btn_box, 
            text="🌙 Dark", 
            command=self._toggle_theme,
            onvalue="Dark",
            offvalue="Light"
        )
        self.theme_switch.select()
        self.theme_switch.pack(side="left", padx=10)

    def _create_sidebar(self):
        self.sidebar_frame = ctk.CTkFrame(self.body_frame, width=320, corner_radius=10)
        self.sidebar_frame.grid(row=0, column=0, sticky="nsew", padx=(0, 8), pady=0)
        self.sidebar_frame.grid_rowconfigure(3, weight=1)

        # 1. Category Filter Section
        cat_header_box = ctk.CTkFrame(self.sidebar_frame, fg_color="transparent")
        cat_header_box.pack(fill="x", padx=10, pady=(10, 5))

        cat_lbl = ctk.CTkLabel(cat_header_box, text="Categories", font=ctk.CTkFont(size=14, weight="bold"))
        cat_lbl.pack(side="left")

        add_cat_btn = ctk.CTkButton(
            cat_header_box, 
            text="+ Category", 
            width=80, 
            height=24, 
            font=ctk.CTkFont(size=11),
            fg_color="gray30",
            command=self.open_add_category_dialog
        )
        add_cat_btn.pack(side="right")

        self.category_opt = ctk.CTkOptionMenu(
            self.sidebar_frame,
            values=["All"],
            command=self._on_category_selected
        )
        self.category_opt.pack(fill="x", padx=10, pady=5)
        self._refresh_categories_dropdown()

        # 2. Revision Status Filter Tabs
        status_lbl = ctk.CTkLabel(self.sidebar_frame, text="Filter Status", font=ctk.CTkFont(size=13, weight="bold"))
        status_lbl.pack(anchor="w", padx=12, pady=(10, 2))

        self.status_segmented = ctk.CTkSegmentedButton(
            self.sidebar_frame,
            values=["All", "Unread", "Practice", "Mastered", "⭐ Starred"],
            command=self._on_status_filter_selected
        )
        self.status_segmented.set("All")
        self.status_segmented.pack(fill="x", padx=10, pady=4)

        # 3. List Header Stats
        self.list_info_lbl = ctk.CTkLabel(
            self.sidebar_frame, 
            text="Questions (0)", 
            font=ctk.CTkFont(size=12, weight="bold"),
            text_color="gray70"
        )
        self.list_info_lbl.pack(anchor="w", padx=12, pady=(8, 4))

        # 4. Scrollable Q&A Cards Container
        self.qa_scroll_frame = ctk.CTkScrollableFrame(self.sidebar_frame, corner_radius=6)
        self.qa_scroll_frame.pack(fill="both", expand=True, padx=8, pady=(0, 8))

    def _create_main_content(self):
        self.main_content_frame = ctk.CTkFrame(self.body_frame, corner_radius=10)
        self.main_content_frame.grid(row=0, column=1, sticky="nsew", padx=0, pady=0)
        self.main_content_frame.grid_rowconfigure(1, weight=1)
        self.main_content_frame.grid_columnconfigure(0, weight=1)

        # --- TOP PLAYBACK STATUS BANNER ---
        self.status_banner = ctk.CTkFrame(self.main_content_frame, height=45, fg_color="#1f2335", corner_radius=8)
        self.status_banner.grid(row=0, column=0, sticky="ew", padx=15, pady=(15, 5))

        self.tts_status_lbl = ctk.CTkLabel(
            self.status_banner, 
            text="⏹️ Ready — Select a question and press Play",
            font=ctk.CTkFont(size=14, weight="bold"),
            text_color="#7aa2f7"
        )
        self.tts_status_lbl.pack(side="left", padx=15, pady=8)

        self.repeat_indicator_lbl = ctk.CTkLabel(
            self.status_banner,
            text="",
            font=ctk.CTkFont(size=12, weight="bold"),
            text_color="#e0af68"
        )
        self.repeat_indicator_lbl.pack(side="right", padx=15, pady=8)

        # --- MIDDLE Q&A VIEW AREA ---
        self.view_scroll = ctk.CTkScrollableFrame(self.main_content_frame, fg_color="transparent")
        self.view_scroll.grid(row=1, column=0, sticky="nsew", padx=15, pady=5)

        # Active Item Meta Bar
        self.item_meta_frame = ctk.CTkFrame(self.view_scroll, fg_color="transparent")
        self.item_meta_frame.pack(fill="x", pady=(0, 10))

        self.item_cat_pill = ctk.CTkLabel(
            self.item_meta_frame, 
            text="📌 General", 
            fg_color="#3b4261", 
            corner_radius=12,
            padx=12, 
            pady=4,
            font=ctk.CTkFont(size=12, weight="bold")
        )
        self.item_cat_pill.pack(side="left")

        self.star_btn = ctk.CTkButton(
            self.item_meta_frame,
            text="☆ Star",
            width=70,
            height=26,
            fg_color="transparent",
            border_width=1,
            command=self._toggle_star_current
        )
        self.star_btn.pack(side="left", padx=10)

        self.status_opt = ctk.CTkOptionMenu(
            self.item_meta_frame,
            values=["unread", "needs_practice", "mastered"],
            command=self._on_item_status_change,
            width=130
        )
        self.status_opt.pack(side="right")

        # Question Card
        self.q_card = ctk.CTkFrame(self.view_scroll, fg_color="#24283b", corner_radius=10)
        self.q_card.pack(fill="x", pady=5)

        q_title = ctk.CTkLabel(
            self.q_card, 
            text="QUESTION", 
            font=ctk.CTkFont(size=11, weight="bold"),
            text_color="#7aa2f7"
        )
        q_title.pack(anchor="w", padx=15, pady=(12, 4))

        self.q_text_lbl = ctk.CTkLabel(
            self.q_card, 
            text="Select a question from the sidebar to start practicing.", 
            font=ctk.CTkFont(size=17, weight="bold"),
            wraplength=700,
            justify="left"
        )
        self.q_text_lbl.pack(anchor="w", padx=15, pady=(0, 15))

        # Answer Card
        self.a_card = ctk.CTkFrame(self.view_scroll, fg_color="#1f2335", corner_radius=10)
        self.a_card.pack(fill="x", pady=(10, 5))

        a_header_box = ctk.CTkFrame(self.a_card, fg_color="transparent")
        a_header_box.pack(fill="x", padx=15, pady=(12, 4))

        a_title = ctk.CTkLabel(
            a_header_box, 
            text="ANSWER", 
            font=ctk.CTkFont(size=11, weight="bold"),
            text_color="#9ece6a"
        )
        a_title.pack(side="left")

        self.reveal_btn = ctk.CTkButton(
            a_header_box,
            text="👁️ Hide Answer",
            width=110,
            height=24,
            font=ctk.CTkFont(size=11),
            fg_color="gray30",
            command=self._toggle_reveal_answer
        )
        self.reveal_btn.pack(side="right")

        self.a_text_lbl = ctk.CTkLabel(
            self.a_card, 
            text="Answers will be displayed here.", 
            font=ctk.CTkFont(size=15),
            wraplength=700,
            justify="left"
        )
        self.a_text_lbl.pack(anchor="w", padx=15, pady=(0, 15))

        # Item Action Buttons (Edit, Delete, Mark Mastered)
        self.item_action_box = ctk.CTkFrame(self.view_scroll, fg_color="transparent")
        self.item_action_box.pack(fill="x", pady=10)

        edit_btn = ctk.CTkButton(
            self.item_action_box, 
            text="✏️ Edit", 
            width=90, 
            fg_color="#3b4261", 
            command=self.open_edit_qa_modal
        )
        edit_btn.pack(side="left", padx=(0, 5))

        del_btn = ctk.CTkButton(
            self.item_action_box, 
            text="🗑️ Delete", 
            width=90, 
            fg_color="#7f1d1d", 
            hover_color="#991b1b",
            command=self._delete_current_item
        )
        del_btn.pack(side="left", padx=5)

        mastered_btn = ctk.CTkButton(
            self.item_action_box, 
            text="✓ Mark Mastered", 
            width=130, 
            fg_color="#16a34a", 
            hover_color="#15803d",
            command=lambda: self._on_item_status_change("mastered")
        )
        mastered_btn.pack(side="right")

        needs_prac_btn = ctk.CTkButton(
            self.item_action_box, 
            text="⚡ Needs Practice", 
            width=130, 
            fg_color="#d97706", 
            hover_color="#b45309",
            command=lambda: self._on_item_status_change("needs_practice")
        )
        needs_prac_btn.pack(side="right", padx=5)

        # --- BOTTOM PLAYBACK & SETTINGS CONTROLS ---
        self._create_playback_deck()

    def _create_playback_deck(self):
        self.controls_frame = ctk.CTkFrame(self.main_content_frame, corner_radius=10)
        self.controls_frame.grid(row=2, column=0, sticky="ew", padx=15, pady=(5, 15))

        # Row 1: Major Transport Buttons (Prev, Play, Pause, Stop, Next, Auto Play)
        transport_box = ctk.CTkFrame(self.controls_frame, fg_color="transparent")
        transport_box.pack(fill="x", padx=15, pady=(12, 8))

        self.prev_btn = ctk.CTkButton(
            transport_box, 
            text="⏮️ Prev", 
            width=80, 
            height=36,
            command=self._on_prev_click
        )
        self.prev_btn.pack(side="left", padx=4)

        self.play_btn = ctk.CTkButton(
            transport_box, 
            text="▶️ Play", 
            width=100, 
            height=36,
            font=ctk.CTkFont(size=14, weight="bold"),
            fg_color="#2563eb",
            hover_color="#1d4ed8",
            command=self._on_play_click
        )
        self.play_btn.pack(side="left", padx=4)

        self.pause_btn = ctk.CTkButton(
            transport_box, 
            text="⏸️ Pause", 
            width=90, 
            height=36,
            fg_color="#d97706",
            hover_color="#b45309",
            command=self._on_pause_click
        )
        self.pause_btn.pack(side="left", padx=4)

        self.stop_btn = ctk.CTkButton(
            transport_box, 
            text="⏹️ Stop", 
            width=85, 
            height=36,
            fg_color="#7f1d1d",
            hover_color="#991b1b",
            command=self._on_stop_click
        )
        self.stop_btn.pack(side="left", padx=4)

        self.next_btn = ctk.CTkButton(
            transport_box, 
            text="Next ⏭️", 
            width=80, 
            height=36,
            command=self._on_next_click
        )
        self.next_btn.pack(side="left", padx=4)

        self.auto_play_switch = ctk.CTkSwitch(
            transport_box,
            text="🔄 Auto Play All",
            font=ctk.CTkFont(weight="bold"),
            command=self._on_auto_play_toggle
        )
        self.auto_play_switch.select()
        self.auto_play_switch.pack(side="right", padx=10)

        # Row 2: TTS Configurations (Repeat Mode, Speech Rate, Active Recall Delay, Voice)
        settings_box = ctk.CTkFrame(self.controls_frame, fg_color="transparent")
        settings_box.pack(fill="x", padx=15, pady=(0, 12))

        # Repeat Mode
        rep_lbl = ctk.CTkLabel(settings_box, text="Repeat:", font=ctk.CTkFont(size=12, weight="bold"))
        rep_lbl.pack(side="left", padx=(0, 4))

        self.repeat_opt = ctk.CTkSegmentedButton(
            settings_box,
            values=["1x", "3x", "5x", "∞ Loop"],
            command=self._on_repeat_mode_change,
            width=180
        )
        self.repeat_opt.set("3x")
        self.repeat_opt.pack(side="left", padx=(0, 15))

        # Repeat Target
        target_lbl = ctk.CTkLabel(settings_box, text="Speak:", font=ctk.CTkFont(size=12, weight="bold"))
        target_lbl.pack(side="left", padx=(0, 4))

        self.target_opt = ctk.CTkOptionMenu(
            settings_box,
            values=["Q & A Both", "Question Only", "Answer Only"],
            command=self._on_target_change,
            width=120
        )
        self.target_opt.pack(side="left", padx=(0, 15))

        # Speed Control Slider
        speed_lbl = ctk.CTkLabel(settings_box, text="Speed:", font=ctk.CTkFont(size=12, weight="bold"))
        speed_lbl.pack(side="left", padx=(0, 4))

        self.speed_val_lbl = ctk.CTkLabel(settings_box, text="1.0x (175 wpm)", font=ctk.CTkFont(size=11))
        self.speed_val_lbl.pack(side="left", padx=(0, 4))

        self.speed_slider = ctk.CTkSlider(
            settings_box,
            from_=100,
            to=280,
            number_of_steps=18,
            width=110,
            command=self._on_speed_slider_change
        )
        self.speed_slider.set(175)
        self.speed_slider.pack(side="left", padx=(0, 15))

        # Active Recall Delay Gap Slider
        delay_lbl = ctk.CTkLabel(settings_box, text="Recall Gap:", font=ctk.CTkFont(size=12, weight="bold"))
        delay_lbl.pack(side="left", padx=(0, 4))

        self.delay_val_lbl = ctk.CTkLabel(settings_box, text="2.0s", font=ctk.CTkFont(size=11))
        self.delay_val_lbl.pack(side="left", padx=(0, 4))

        self.delay_slider = ctk.CTkSlider(
            settings_box,
            from_=0.0,
            to=6.0,
            number_of_steps=12,
            width=100,
            command=self._on_delay_slider_change
        )
        self.delay_slider.set(2.0)
        self.delay_slider.pack(side="left", padx=(0, 15))

        # Voice Selector
        voice_lbl = ctk.CTkLabel(settings_box, text="Voice:", font=ctk.CTkFont(size=12, weight="bold"))
        voice_lbl.pack(side="left", padx=(0, 4))

        self.voices = self.tts.get_available_voices()
        voice_names = [v["name"] for v in self.voices]
        self.voice_opt = ctk.CTkOptionMenu(
            settings_box,
            values=voice_names if voice_names else ["Default Voice"],
            command=self._on_voice_selected,
            width=140
        )
        if voice_names:
            self.voice_opt.set(voice_names[0])
            self.tts.set_voice(self.voices[0]["id"])
        self.voice_opt.pack(side="left")

    # -------------------------------------------------------------
    # DATA LOADING & FILTERING
    # -------------------------------------------------------------
    def refresh_qa_list(self):
        """Fetches filtered Q&A items from database and updates sidebar scroll list."""
        self.playlist = self.db.get_filtered_qa(
            category=self.selected_category,
            search_query=self.search_query,
            status_filter=self.selected_status
        )

        # Clear existing card widgets
        for widget in self.qa_scroll_frame.winfo_children():
            widget.destroy()
        self.qa_card_widgets = []

        self.list_info_lbl.configure(text=f"Questions ({len(self.playlist)})")
        self._update_progress_stats()

        if not self.playlist:
            no_data_lbl = ctk.CTkLabel(
                self.qa_scroll_frame,
                text="No questions found matching your filter.\nClick '+ Add Q&A' to create one!",
                justify="center",
                text_color="gray60"
            )
            no_data_lbl.pack(pady=30)
            self._display_selected_item(None)
            return

        # Ensure valid current index
        if self.current_item_index >= len(self.playlist):
            self.current_item_index = 0

        # Build card widgets
        for idx, item in enumerate(self.playlist):
            card = self._build_qa_list_card(idx, item)
            self.qa_card_widgets.append(card)

        # Highlight & display current item
        self.select_item(self.current_item_index)

    def _build_qa_list_card(self, index, item):
        is_selected = (index == self.current_item_index)
        bg_col = "#3b4261" if is_selected else "#24283b"

        card = ctk.CTkFrame(self.qa_scroll_frame, fg_color=bg_col, corner_radius=8, cursor="hand2")
        card.pack(fill="x", pady=4, padx=2)

        # Card content grid
        card.grid_columnconfigure(0, weight=1)

        # Question Title
        q_snippet = item["question"]
        if len(q_snippet) > 42:
            q_snippet = q_snippet[:40] + "..."

        q_lbl = ctk.CTkLabel(
            card, 
            text=f"{index+1}. {q_snippet}", 
            font=ctk.CTkFont(size=13, weight="bold" if is_selected else "normal"),
            anchor="w",
            justify="left"
        )
        q_lbl.grid(row=0, column=0, sticky="w", padx=10, pady=(8, 2))

        # Bottom Meta Row (Category Pill + Status Badge + Star)
        meta_row = ctk.CTkFrame(card, fg_color="transparent")
        meta_row.grid(row=1, column=0, sticky="ew", padx=10, pady=(0, 8))

        cat_icon = get_category_icon(item["category"])
        cat_badge = ctk.CTkLabel(
            meta_row, 
            text=f"{cat_icon} {item['category']}", 
            font=ctk.CTkFont(size=10),
            text_color="#a9b1d6"
        )
        cat_badge.pack(side="left")

        # Status indicator badge
        status_key = item.get("status", "unread")
        status_info = STATUS_BADGES.get(status_key, STATUS_BADGES["unread"])
        status_color = status_info["color_dark"] if self.current_theme == "Dark" else status_info["color_light"]

        stat_badge = ctk.CTkLabel(
            meta_row, 
            text=status_info["label"], 
            font=ctk.CTkFont(size=10, weight="bold"),
            text_color=status_color
        )
        stat_badge.pack(side="left", padx=8)

        if item.get("is_starred"):
            star_lbl = ctk.CTkLabel(meta_row, text="★", text_color="#e0af68", font=ctk.CTkFont(size=12))
            star_lbl.pack(side="right")

        # Click event handlers
        for element in (card, q_lbl, meta_row, cat_badge, stat_badge):
            element.bind("<Button-1>", lambda e, idx=index: self.select_item(idx))

        return card

    def select_item(self, index):
        if not self.playlist or index < 0 or index >= len(self.playlist):
            return

        self.current_item_index = index
        self.selected_item = self.playlist[index]

        # Update card background highlights
        for idx, card in enumerate(self.qa_card_widgets):
            if idx == index:
                card.configure(fg_color="#3b4261")
            else:
                card.configure(fg_color="#24283b")

        self._display_selected_item(self.selected_item)

    def _display_selected_item(self, item):
        if not item:
            self.q_text_lbl.configure(text="No question selected.")
            self.a_text_lbl.configure(text="")
            self.item_cat_pill.configure(text="📌 General")
            self.star_btn.configure(text="☆ Star")
            return

        cat_icon = get_category_icon(item["category"])
        self.item_cat_pill.configure(text=f"{cat_icon} {item['category']}")
        self.q_text_lbl.configure(text=item["question"])
        
        if self.answer_revealed:
            self.a_text_lbl.configure(text=item["answer"])
            self.reveal_btn.configure(text="👁️ Hide Answer")
        else:
            self.a_text_lbl.configure(text="• • • (Click 'Reveal Answer' or press Play to show) • • •")
            self.reveal_btn.configure(text="👁️ Reveal Answer")

        self.star_btn.configure(text="★ Starred" if item.get("is_starred") else "☆ Star")
        self.status_opt.set(item.get("status", "unread"))

    def _update_progress_stats(self):
        stats = self.db.get_stats()
        mastered_pct = stats["percent_mastered"]
        self.progress_bar.set(mastered_pct / 100.0)
        self.progress_lbl.configure(text=f"Mastered: {mastered_pct}% ({stats['mastered']}/{stats['total']})")

    def _refresh_categories_dropdown(self):
        cats = ["All"] + self.db.get_all_categories()
        self.category_opt.configure(values=cats)

    # -------------------------------------------------------------
    # TTS & PLAYBACK HANDLERS
    # -------------------------------------------------------------
    def _on_play_click(self):
        if not self.playlist:
            messagebox.showinfo("No Questions", "There are no questions in the current playlist to play.")
            return

        # Ensure answer is revealed when playing
        self.answer_revealed = True
        self._display_selected_item(self.selected_item)

        repeat_val = self._parse_repeat_val(self.repeat_opt.get())
        auto_play = self.auto_play_switch.get() == 1
        qa_gap = self.delay_slider.get()

        if self.tts.is_paused:
            self.tts.resume()
        else:
            self.tts.play(
                playlist=self.playlist,
                start_index=self.current_item_index,
                repeat_mode=repeat_val,
                auto_play=auto_play,
                qa_gap=qa_gap
            )

    def _on_pause_click(self):
        if self.tts.is_paused:
            self.tts.resume()
        else:
            self.tts.pause()

    def _on_stop_click(self):
        self.tts.stop()

    def _on_prev_click(self):
        if self.current_item_index > 0:
            self.select_item(self.current_item_index - 1)
            if self.tts.state != TTSEngine.STATE_STOPPED:
                self._on_play_click()

    def _on_next_click(self):
        if self.current_item_index < len(self.playlist) - 1:
            self.select_item(self.current_item_index + 1)
            if self.tts.state != TTSEngine.STATE_STOPPED:
                self._on_play_click()

    def _on_auto_play_toggle(self):
        self.tts.auto_play = (self.auto_play_switch.get() == 1)

    def _on_repeat_mode_change(self, choice):
        val = self._parse_repeat_val(choice)
        self.tts.repeat_mode = val

    def _parse_repeat_val(self, choice):
        if choice == "1x": return 1
        if choice == "3x": return 3
        if choice == "5x": return 5
        if "Loop" in choice or "∞" in choice: return 9999
        return 3

    def _on_target_change(self, choice):
        if choice == "Question Only":
            self.tts.repeat_target = "question_only"
        elif choice == "Answer Only":
            self.tts.repeat_target = "answer_only"
        else:
            self.tts.repeat_target = "both"

    def _on_speed_slider_change(self, value):
        wpm = int(value)
        # Convert WPM to nominal speed multiplier for UI
        multiplier = round(wpm / 175.0, 2)
        self.speed_val_lbl.configure(text=f"{multiplier}x ({wpm} wpm)")
        self.tts.set_rate(wpm)

    def _on_delay_slider_change(self, value):
        delay = round(value, 1)
        self.delay_val_lbl.configure(text=f"{delay}s")
        self.tts.qa_gap_delay = delay

    def _on_voice_selected(self, voice_name):
        for v in self.voices:
            if v["name"] == voice_name:
                self.tts.set_voice(v["id"])
                break

    # --- TTS Thread Callbacks ---
    def _on_tts_status_change(self, status_text, item, current_rep, max_rep):
        self.after(0, lambda: self._update_tts_status_ui(status_text, current_rep, max_rep))

    def _update_tts_status_ui(self, status_text, current_rep, max_rep):
        self.tts_status_lbl.configure(text=status_text)
        if max_rep > 0:
            rep_str = "Loop ∞" if max_rep == 9999 else f"Repeat {current_rep}/{max_rep}"
            self.repeat_indicator_lbl.configure(text=rep_str)
        else:
            self.repeat_indicator_lbl.configure(text="")

    def _on_tts_item_changed(self, item_index, item):
        self.after(0, lambda: self.select_item(item_index))

    def _on_tts_finished(self):
        self.after(0, lambda: self.tts_status_lbl.configure(text="🏁 Finished Playlist"))

    # -------------------------------------------------------------
    # ITEM ACTIONS & EVENT HANDLERS
    # -------------------------------------------------------------
    def _toggle_reveal_answer(self):
        self.answer_revealed = not self.answer_revealed
        self._display_selected_item(self.selected_item)

    def _toggle_star_current(self):
        if not self.selected_item:
            return
        new_starred = self.db.toggle_star(self.selected_item["id"])
        self.selected_item["is_starred"] = new_starred
        self.star_btn.configure(text="★ Starred" if new_starred else "☆ Star")
        self.refresh_qa_list()

    def _on_item_status_change(self, new_status):
        if not self.selected_item:
            return
        self.db.update_status(self.selected_item["id"], new_status)
        self.selected_item["status"] = new_status
        self.status_opt.set(new_status)
        self.refresh_qa_list()

    def _delete_current_item(self):
        if not self.selected_item:
            return
        confirm = messagebox.askyesno("Confirm Delete", f"Are you sure you want to delete this question?\n\n'{self.selected_item['question']}'")
        if confirm:
            self.db.delete_qa(self.selected_item["id"])
            self.refresh_qa_list()

    def _on_search_key_release(self, event):
        self.search_query = self.search_entry.get().strip()
        self.refresh_qa_list()

    def _on_category_selected(self, category):
        self.selected_category = category
        self.refresh_qa_list()

    def _on_status_filter_selected(self, status):
        self.selected_status = status
        self.refresh_qa_list()

    def _toggle_theme(self):
        mode = self.theme_switch.get()
        ctk.set_appearance_mode(mode)
        self.current_theme = mode

    # -------------------------------------------------------------
    # ADD / EDIT MODALS
    # -------------------------------------------------------------
    def open_add_qa_modal(self):
        self._open_qa_dialog("Add New Interview Q&A")

    def open_edit_qa_modal(self):
        if not self.selected_item:
            messagebox.showwarning("No Selection", "Please select a question to edit.")
            return
        self._open_qa_dialog("Edit Interview Q&A", item=self.selected_item)

    def _open_qa_dialog(self, title, item=None):
        dialog = ctk.CTkToplevel(self)
        dialog.title(title)
        dialog.geometry("560x520")
        dialog.grab_set()

        # Category
        cat_lbl = ctk.CTkLabel(dialog, text="Category:", font=ctk.CTkFont(weight="bold"))
        cat_lbl.pack(anchor="w", padx=20, pady=(15, 2))

        categories = self.db.get_all_categories()
        cat_opt = ctk.CTkOptionMenu(dialog, values=categories)
        if item:
            cat_opt.set(item["category"])
        elif self.selected_category != "All":
            cat_opt.set(self.selected_category)
        cat_opt.pack(fill="x", padx=20)

        # Question
        q_lbl = ctk.CTkLabel(dialog, text="Question:", font=ctk.CTkFont(weight="bold"))
        q_lbl.pack(anchor="w", padx=20, pady=(10, 2))

        q_entry = ctk.CTkTextbox(dialog, height=80)
        if item:
            q_entry.insert("1.0", item["question"])
        q_entry.pack(fill="x", padx=20)

        # Answer
        a_lbl = ctk.CTkLabel(dialog, text="Answer:", font=ctk.CTkFont(weight="bold"))
        a_lbl.pack(anchor="w", padx=20, pady=(10, 2))

        a_entry = ctk.CTkTextbox(dialog, height=140)
        if item:
            a_entry.insert("1.0", item["answer"])
        a_entry.pack(fill="x", padx=20)

        # Repeat Count
        rep_frame = ctk.CTkFrame(dialog, fg_color="transparent")
        rep_frame.pack(fill="x", padx=20, pady=10)

        r_lbl = ctk.CTkLabel(rep_frame, text="Default Repeats:", font=ctk.CTkFont(weight="bold"))
        r_lbl.pack(side="left")

        r_opt = ctk.CTkSegmentedButton(rep_frame, values=["1x", "3x", "5x"])
        r_opt.set(f"{item['repeat_count']}x" if item else "3x")
        r_opt.pack(side="left", padx=10)

        # Save / Cancel Buttons
        btn_box = ctk.CTkFrame(dialog, fg_color="transparent")
        btn_box.pack(fill="x", padx=20, pady=15)

        def save_action():
            q_text = q_entry.get("1.0", "end-1c").strip()
            a_text = a_entry.get("1.0", "end-1c").strip()
            cat = cat_opt.get()
            rep_str = r_opt.get().replace("x", "")
            rep_cnt = int(rep_str) if rep_str.isdigit() else 3

            if not q_text or not a_text:
                messagebox.showerror("Validation Error", "Both Question and Answer fields are required.")
                return

            if item:
                self.db.update_qa(
                    qa_id=item["id"],
                    question=q_text,
                    answer=a_text,
                    category=cat,
                    status=item.get("status", "unread"),
                    is_starred=item.get("is_starred", 0),
                    repeat_count=rep_cnt
                )
            else:
                self.db.add_qa(
                    question=q_text,
                    answer=a_text,
                    category=cat,
                    repeat_count=rep_cnt
                )

            dialog.destroy()
            self.refresh_qa_list()

        save_btn = ctk.CTkButton(btn_box, text="Save Q&A", fg_color="#2563eb", command=save_action)
        save_btn.pack(side="right", padx=5)

        cancel_btn = ctk.CTkButton(btn_box, text="Cancel", fg_color="gray30", command=dialog.destroy)
        cancel_btn.pack(side="right", padx=5)

    def open_add_category_dialog(self):
        dialog = ctk.CTkInputDialog(text="Enter new category name:", title="Add Category")
        new_cat = dialog.get_input()
        if new_cat and new_cat.strip():
            self.db.add_category(new_cat.strip())
            self._refresh_categories_dropdown()
            self.category_opt.set(new_cat.strip())
            self._on_category_selected(new_cat.strip())

    # -------------------------------------------------------------
    # IMPORT / EXPORT HANDLERS
    # -------------------------------------------------------------
    def _handle_import_export_option(self, option):
        if option == "📥 Import JSON":
            self._import_file("json")
        elif option == "📥 Import CSV":
            self._import_file("csv")
        elif option == "📤 Export JSON":
            self._export_file("json")
        elif option == "📤 Export CSV":
            self._export_file("csv")

    def _import_file(self, file_type):
        file_path = filedialog.askopenfilename(
            title=f"Import Q&A from {file_type.upper()}",
            filetypes=[(f"{file_type.upper()} Files", f"*.{file_type}"), ("All Files", "*.*")]
        )
        if not file_path:
            return

        try:
            if file_type == "json":
                imported = self.db.import_from_json(file_path)
            else:
                imported = self.db.import_from_csv(file_path)

            messagebox.showinfo("Import Successful", f"Successfully imported {imported} Q&A items.")
            self._refresh_categories_dropdown()
            self.refresh_qa_list()
        except Exception as e:
            messagebox.showerror("Import Failed", f"Error reading file: {e}")

    def _export_file(self, file_type):
        file_path = filedialog.asksaveasfilename(
            title=f"Export Q&A to {file_type.upper()}",
            defaultextension=f".{file_type}",
            filetypes=[(f"{file_type.upper()} Files", f"*.{file_type}")]
        )
        if not file_path:
            return

        try:
            if file_type == "json":
                exported = self.db.export_to_json(file_path)
            else:
                exported = self.db.export_to_csv(file_path)

            messagebox.showinfo("Export Successful", f"Exported {exported} Q&A items to {os.path.basename(file_path)}.")
        except Exception as e:
            messagebox.showerror("Export Failed", f"Error writing file: {e}")

    # -------------------------------------------------------------
    # KEYBOARD SHORTCUTS
    # -------------------------------------------------------------
    def _bind_keyboard_shortcuts(self):
        self.bind("<space>", lambda e: self._on_pause_click() if self.tts.state != TTSEngine.STATE_STOPPED else self._on_play_click())
        self.bind("<Left>", lambda e: self._on_prev_click())
        self.bind("<Right>", lambda e: self._on_next_click())
        self.bind("<s>", lambda e: self._on_stop_click())
        self.bind("<S>", lambda e: self._on_stop_click())
        self.bind("<m>", lambda e: self._on_item_status_change("mastered"))
        self.bind("<M>", lambda e: self._on_item_status_change("mastered"))
