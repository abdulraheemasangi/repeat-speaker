import threading
import queue
import time
import pyttsx3

try:
    import pythoncom
except ImportError:
    pythoncom = None

class TTSEngine:
    """
    Thread-safe TTS engine wrapper using pyttsx3.
    Manages speech queue, repeats, active-recall delays, auto-play, voice & speed adjustments.
    """
    
    STATE_STOPPED = "STOPPED"
    STATE_PLAYING_QUESTION = "PLAYING_QUESTION"
    STATE_GAP_BEFORE_ANSWER = "GAP_BEFORE_ANSWER"
    STATE_PLAYING_ANSWER = "PLAYING_ANSWER"
    STATE_GAP_BEFORE_NEXT = "GAP_BEFORE_NEXT"
    STATE_PAUSED = "PAUSED"

    def __init__(self):
        self.cmd_queue = queue.Queue()
        self.worker_thread = None
        self.is_running = False
        
        # Audio properties
        self.voice_id = None
        self.rate = 175  # Words per minute (100 - 300)
        self.volume = 1.0  # 0.0 to 1.0
        
        # Playback configuration
        self.playlist = []
        self.current_index = 0
        self.repeat_mode = 3  # 1, 3, 5, or 9999 (loop)
        self.auto_play = True
        self.qa_gap_delay = 2.0  # seconds delay between question and answer
        self.item_gap_delay = 1.5  # seconds delay between items
        self.repeat_target = "both"  # "both", "question_only", "answer_only"
        
        # Internal playback state
        self.state = self.STATE_STOPPED
        self.is_paused = False
        self.stop_requested = False
        
        # Callbacks
        self.on_status_change = None  # fn(state_text, item, current_repeat, max_repeats)
        self.on_item_changed = None   # fn(item_index, item)
        self.on_finished = None       # fn()

        self._start_worker()

    def _start_worker(self):
        self.is_running = True
        self.worker_thread = threading.Thread(target=self._worker_loop, daemon=True)
        self.worker_thread.start()

    def _init_pyttsx3_engine(self):
        if pythoncom:
            try:
                pythoncom.CoInitialize()
            except Exception:
                pass
        
        engine = pyttsx3.init()
        voices = engine.getProperty('voices')
        
        # Default voice setting
        if not self.voice_id and voices:
            self.voice_id = voices[0].id
            
        if self.voice_id:
            try:
                engine.setProperty('voice', self.voice_id)
            except Exception:
                pass
                
        engine.setProperty('rate', self.rate)
        engine.setProperty('volume', self.volume)
        return engine

    def get_available_voices(self):
        """Returns list of dicts with voice id and friendly name."""
        try:
            if pythoncom:
                try:
                    pythoncom.CoInitialize()
                except Exception:
                    pass
            temp_engine = pyttsx3.init()
            voices = temp_engine.getProperty('voices')
            voice_list = []
            for v in voices:
                # Clean up voice name
                name = v.name
                if "Microsoft " in name:
                    name = name.replace("Microsoft ", "").replace(" Desktop - English (United States)", "").replace(" - English (United States)", "")
                voice_list.append({
                    "id": v.id,
                    "name": name,
                    "full_name": v.name,
                    "gender": "Female" if "zira" in v.name.lower() or "eva" in v.name.lower() or "female" in v.name.lower() else "Male"
                })
            return voice_list
        except Exception as e:
            print(f"Error fetching voices: {e}")
            return [{"id": "default", "name": "Default Voice", "gender": "Standard"}]

    def set_voice(self, voice_id):
        self.voice_id = voice_id
        self.cmd_queue.put(("SET_VOICE", voice_id))

    def set_rate(self, rate):
        """Set speech rate (WPM: 100 - 300)."""
        self.rate = int(max(80, min(350, rate)))
        self.cmd_queue.put(("SET_RATE", self.rate))

    def set_volume(self, volume):
        self.volume = max(0.0, min(1.0, volume))
        self.cmd_queue.put(("SET_VOLUME", self.volume))

    def play(self, playlist=None, start_index=0, repeat_mode=None, auto_play=None, qa_gap=None):
        if playlist is not None:
            self.playlist = playlist
            self.current_index = max(0, min(len(playlist) - 1, start_index)) if playlist else 0
            
        if repeat_mode is not None:
            self.repeat_mode = repeat_mode
            
        if auto_play is not None:
            self.auto_play = auto_play
            
        if qa_gap is not None:
            self.qa_gap_delay = qa_gap

        self.is_paused = False
        self.stop_requested = False
        self.cmd_queue.put(("PLAY", None))

    def pause(self):
        self.is_paused = True
        self.cmd_queue.put(("PAUSE", None))

    def resume(self):
        self.is_paused = False
        self.cmd_queue.put(("RESUME", None))

    def stop(self):
        self.stop_requested = True
        self.is_paused = False
        self.cmd_queue.put(("STOP", None))

    def next_item(self):
        if self.playlist and self.current_index < len(self.playlist) - 1:
            self.current_index += 1
            self.play()

    def prev_item(self):
        if self.playlist and self.current_index > 0:
            self.current_index -= 1
            self.play()

    def _worker_loop(self):
        engine = None
        
        while self.is_running:
            try:
                # Check for command from queue
                try:
                    cmd, arg = self.cmd_queue.get(timeout=0.1)
                except queue.Empty:
                    cmd, arg = None, None

                if cmd == "SET_VOICE" and engine:
                    try:
                        engine.setProperty('voice', arg)
                    except Exception:
                        pass
                elif cmd == "SET_RATE" and engine:
                    try:
                        engine.setProperty('rate', arg)
                    except Exception:
                        pass
                elif cmd == "SET_VOLUME" and engine:
                    try:
                        engine.setProperty('volume', arg)
                    except Exception:
                        pass
                elif cmd == "STOP":
                    if engine:
                        try:
                            engine.stop()
                        except Exception:
                            pass
                    self.state = self.STATE_STOPPED
                    self._notify_status("Stopped", None, 0, 0)
                elif cmd == "PLAY":
                    if not self.playlist:
                        self.state = self.STATE_STOPPED
                        self._notify_status("Playlist empty", None, 0, 0)
                        continue
                        
                    # Re-initialize engine for fresh speech session
                    if engine is None:
                        engine = self._init_pyttsx3_engine()
                    else:
                        try:
                            engine.setProperty('voice', self.voice_id)
                            engine.setProperty('rate', self.rate)
                            engine.setProperty('volume', self.volume)
                        except Exception:
                            pass

                    self._execute_playback(engine)

            except Exception as e:
                print(f"Error in TTS worker loop: {e}")
                time.sleep(0.2)

    def _execute_playback(self, engine):
        """Executes current item repetition and auto-play progression."""
        self.stop_requested = False
        
        while self.current_index < len(self.playlist) and not self.stop_requested:
            item = self.playlist[self.current_index]
            
            if self.on_item_changed:
                self.on_item_changed(self.current_index, item)

            item_repeats = item.get("repeat_count", self.repeat_mode)
            if self.repeat_mode == 9999: # Unlimited loop
                max_repeats = 9999
            else:
                max_repeats = item_repeats if item_repeats else self.repeat_mode

            rep = 1
            while rep <= max_repeats and not self.stop_requested:
                # --- Step A: Speak Question ---
                if self.repeat_target in ("both", "question_only"):
                    self.state = self.STATE_PLAYING_QUESTION
                    rep_str = "Loop ∞" if max_repeats == 9999 else f"Repeat {rep}/{max_repeats}"
                    self._notify_status(f"🔊 Question ({rep_str})", item, rep, max_repeats)
                    
                    self._speak_text(engine, item["question"])
                    if self.stop_requested:
                        break
                    self._wait_while_paused()
                    if self.stop_requested:
                        break

                # --- Step B: Recall Delay Gap before Answer ---
                if self.qa_gap_delay > 0 and self.repeat_target != "question_only":
                    self.state = self.STATE_GAP_BEFORE_ANSWER
                    self._notify_status(f"⏱️ Pause {self.qa_gap_delay:.1f}s (Active Recall)", item, rep, max_repeats)
                    self._sleep_interruptible(self.qa_gap_delay)
                    if self.stop_requested:
                        break
                    self._wait_while_paused()
                    if self.stop_requested:
                        break

                # --- Step C: Speak Answer ---
                if self.repeat_target in ("both", "answer_only"):
                    self.state = self.STATE_PLAYING_ANSWER
                    rep_str = "Loop ∞" if max_repeats == 9999 else f"Repeat {rep}/{max_repeats}"
                    self._notify_status(f"🔊 Answer ({rep_str})", item, rep, max_repeats)
                    
                    self._speak_text(engine, item["answer"])
                    if self.stop_requested:
                        break
                    self._wait_while_paused()
                    if self.stop_requested:
                        break

                # --- Step D: Short gap between repetitions ---
                if rep < max_repeats:
                    self._sleep_interruptible(0.8)
                    
                rep += 1

            if self.stop_requested:
                break

            # If Auto Play is enabled, advance to next item
            if self.auto_play and self.current_index < len(self.playlist) - 1:
                self.state = self.STATE_GAP_BEFORE_NEXT
                self._notify_status(f"⏱️ Next item in {self.item_gap_delay:.1f}s...", item, max_repeats, max_repeats)
                self._sleep_interruptible(self.item_gap_delay)
                if self.stop_requested:
                    break
                self.current_index += 1
            else:
                # Reached end or auto play disabled
                break

        self.state = self.STATE_STOPPED
        if not self.stop_requested:
            self._notify_status("Finished Playlist", None, 0, 0)
            if self.on_finished:
                self.on_finished()
        else:
            self._notify_status("Stopped", None, 0, 0)

    def _speak_text(self, engine, text):
        """Speaks text using pyttsx3 in chunked or direct calls while handling pause/stop commands."""
        if not text or not engine:
            return

        try:
            # Drain any pending commands before speaking
            self._process_pending_cmds(engine)
            engine.say(text)
            engine.runAndWait()
        except Exception as e:
            print(f"Speech error: {e}")

    def _process_pending_cmds(self, engine):
        while not self.cmd_queue.empty():
            try:
                cmd, arg = self.cmd_queue.get_nowait()
                if cmd == "SET_VOICE":
                    engine.setProperty('voice', arg)
                elif cmd == "SET_RATE":
                    engine.setProperty('rate', arg)
                elif cmd == "SET_VOLUME":
                    engine.setProperty('volume', arg)
            except Exception:
                pass

    def _wait_while_paused(self):
        while self.is_paused and not self.stop_requested:
            self.state = self.STATE_PAUSED
            self._notify_status("⏸️ Paused", None, 0, 0)
            time.sleep(0.1)

    def _sleep_interruptible(self, seconds):
        start = time.time()
        while time.time() - start < seconds:
            if self.stop_requested:
                break
            self._wait_while_paused()
            if self.stop_requested:
                break
            time.sleep(0.05)

    def _notify_status(self, status_text, item, current_rep, max_rep):
        if self.on_status_change:
            self.on_status_change(status_text, item, current_rep, max_rep)
