"""
Main Launcher for Interview Prep - Text to Speech Repeater App
"""

import sys
import os

from app import InterviewPrepApp

def main():
    print("Launching Interview Prep - Text to Speech Repeater Desktop App...")
    app = InterviewPrepApp()
    app.mainloop()

if __name__ == "__main__":
    main()
