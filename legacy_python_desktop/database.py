import sqlite3
import json
import csv
import os
from datetime import datetime

DEFAULT_DB_PATH = "interview_prep.db"

class DatabaseManager:
    def __init__(self, db_path=DEFAULT_DB_PATH):
        self.db_path = db_path
        self.init_db()

    def get_connection(self):
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def _exec_commit(self, query, params=()):
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute(query, params)
            conn.commit()
            return cursor.lastrowid, cursor.rowcount
        finally:
            conn.close()

    def init_db(self):
        """Initialize database schema and tables."""
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            
            # Create categories table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS categories (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT UNIQUE NOT NULL
                )
            """)
            
            # Create Q&A items table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS qa_items (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    category TEXT NOT NULL DEFAULT 'General',
                    question TEXT NOT NULL,
                    answer TEXT NOT NULL,
                    status TEXT NOT NULL DEFAULT 'unread',
                    is_starred INTEGER NOT NULL DEFAULT 0,
                    repeat_count INTEGER NOT NULL DEFAULT 3,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            # Insert default categories if empty
            cursor.execute("SELECT COUNT(*) FROM categories")
            if cursor.fetchone()[0] == 0:
                default_cats = ["General", "HR", "Technical", "Behavioral", "System Design", "Python", "Web Development"]
                cursor.executemany("INSERT INTO categories (name) VALUES (?)", [(cat,) for cat in default_cats])
            
            conn.commit()
        finally:
            conn.close()

    # --- Category Management ---
    def get_all_categories(self):
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT name FROM categories ORDER BY name ASC")
            return [row["name"] for row in cursor.fetchall()]
        finally:
            conn.close()

    def add_category(self, category_name):
        category_name = category_name.strip()
        if not category_name:
            return False
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("INSERT OR IGNORE INTO categories (name) VALUES (?)", (category_name,))
            conn.commit()
            return True
        except Exception as e:
            print(f"Error adding category: {e}")
            return False
        finally:
            conn.close()

    def delete_category(self, category_name):
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM categories WHERE name = ?", (category_name,))
            conn.commit()
        finally:
            conn.close()

    # --- Q&A CRUD ---
    def add_qa(self, question, answer, category="General", status="unread", is_starred=0, repeat_count=3):
        question = question.strip()
        answer = answer.strip()
        category = category.strip() or "General"
        
        self.add_category(category)
        
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            now = datetime.now().isoformat()
            cursor.execute("""
                INSERT INTO qa_items (question, answer, category, status, is_starred, repeat_count, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (question, answer, category, status, 1 if is_starred else 0, repeat_count, now, now))
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def update_qa(self, qa_id, question, answer, category="General", status="unread", is_starred=0, repeat_count=3):
        question = question.strip()
        answer = answer.strip()
        category = category.strip() or "General"
        
        self.add_category(category)
        
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            now = datetime.now().isoformat()
            cursor.execute("""
                UPDATE qa_items
                SET question = ?, answer = ?, category = ?, status = ?, is_starred = ?, repeat_count = ?, updated_at = ?
                WHERE id = ?
            """, (question, answer, category, status, 1 if is_starred else 0, repeat_count, now, qa_id))
            conn.commit()
            return cursor.rowcount > 0
        finally:
            conn.close()

    def delete_qa(self, qa_id):
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM qa_items WHERE id = ?", (qa_id,))
            conn.commit()
            return cursor.rowcount > 0
        finally:
            conn.close()

    def get_qa_by_id(self, qa_id):
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM qa_items WHERE id = ?", (qa_id,))
            row = cursor.fetchone()
            return dict(row) if row else None
        finally:
            conn.close()

    def get_filtered_qa(self, category=None, search_query=None, status_filter=None, starred_only=False):
        """Fetch items filtered by category, search text, status, or starred."""
        query = "SELECT * FROM qa_items WHERE 1=1"
        params = []
        
        if category and category != "All":
            query += " AND category = ?"
            params.append(category)
            
        if search_query and search_query.strip():
            query += " AND (question LIKE ? OR answer LIKE ? OR category LIKE ?)"
            term = f"%{search_query.strip()}%"
            params.extend([term, term, term])
            
        if status_filter and status_filter != "All":
            if status_filter.lower() == "starred":
                query += " AND is_starred = 1"
            else:
                query += " AND status = ?"
                params.append(status_filter.lower())
                
        if starred_only:
            query += " AND is_starred = 1"
            
        query += " ORDER BY id DESC"
        
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute(query, params)
            return [dict(row) for row in cursor.fetchall()]
        finally:
            conn.close()

    def update_status(self, qa_id, new_status):
        valid_statuses = ('unread', 'needs_practice', 'mastered')
        if new_status not in valid_statuses:
            return False
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            now = datetime.now().isoformat()
            cursor.execute("UPDATE qa_items SET status = ?, updated_at = ? WHERE id = ?", (new_status, now, qa_id))
            conn.commit()
            return cursor.rowcount > 0
        finally:
            conn.close()

    def toggle_star(self, qa_id):
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT is_starred FROM qa_items WHERE id = ?", (qa_id,))
            row = cursor.fetchone()
            if not row:
                return False
            new_star = 0 if row["is_starred"] else 1
            now = datetime.now().isoformat()
            cursor.execute("UPDATE qa_items SET is_starred = ?, updated_at = ? WHERE id = ?", (new_star, now, qa_id))
            conn.commit()
            return new_star
        finally:
            conn.close()

    def get_stats(self):
        """Returns stats summary dictionary."""
        conn = self.get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM qa_items")
            total = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM qa_items WHERE status = 'mastered'")
            mastered = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM qa_items WHERE status = 'needs_practice'")
            needs_practice = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM qa_items WHERE status = 'unread'")
            unread = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM qa_items WHERE is_starred = 1")
            starred = cursor.fetchone()[0]
            
            percent_mastered = round((mastered / total * 100), 1) if total > 0 else 0.0
            
            return {
                "total": total,
                "mastered": mastered,
                "needs_practice": needs_practice,
                "unread": unread,
                "starred": starred,
                "percent_mastered": percent_mastered
            }
        finally:
            conn.close()

    # --- Import / Export ---
    def export_to_json(self, file_path):
        items = self.get_filtered_qa()
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(items, f, indent=2, ensure_ascii=False)
        return len(items)

    def import_from_json(self, file_path):
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        count = 0
        if isinstance(data, list):
            for item in data:
                if "question" in item and "answer" in item:
                    self.add_qa(
                        question=item["question"],
                        answer=item["answer"],
                        category=item.get("category", "General"),
                        status=item.get("status", "unread"),
                        is_starred=item.get("is_starred", 0),
                        repeat_count=item.get("repeat_count", 3)
                    )
                    count += 1
        return count

    def export_to_csv(self, file_path):
        items = self.get_filtered_qa()
        fields = ["id", "category", "question", "answer", "status", "is_starred", "repeat_count", "created_at"]
        with open(file_path, "w", newline="", encoding="utf-8-sig") as f:
            writer = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
            writer.writeheader()
            writer.writerows(items)
        return len(items)

    def import_from_csv(self, file_path):
        count = 0
        with open(file_path, "r", encoding="utf-8-sig") as f:
            reader = csv.DictReader(f)
            for row in reader:
                if "question" in row and "answer" in row:
                    self.add_qa(
                        question=row["question"],
                        answer=row["answer"],
                        category=row.get("category", "General"),
                        status=row.get("status", "unread"),
                        is_starred=int(row.get("is_starred", 0)),
                        repeat_count=int(row.get("repeat_count", 3))
                    )
                    count += 1
        return count
