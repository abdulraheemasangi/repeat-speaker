"""
Sample data for Interview Prep TTS Repeater App.
Pre-populates database on first launch with clear, speakable interview Q&A.
"""

SAMPLE_QA_ITEMS = [
    {
        "category": "HR",
        "question": "Tell me about yourself and your background.",
        "answer": "I am a dedicated software developer with expertise in building desktop applications, web interfaces, and backend systems. I focus on writing clean, efficient, and user-centric software while continuously learning modern technologies.",
        "status": "unread",
        "is_starred": 1,
        "repeat_count": 3
    },
    {
        "category": "HR",
        "question": "What are your greatest strengths?",
        "answer": "My greatest strengths are my strong problem-solving abilities, fast learning capacity, and persistence when troubleshooting complex engineering challenges. I also communicate effectively with cross-functional teams.",
        "status": "unread",
        "is_starred": 0,
        "repeat_count": 3
    },
    {
        "category": "HR",
        "question": "Where do you see yourself in 5 years?",
        "answer": "In 5 years, I see myself taking on a technical leadership role, architecting scalable application solutions, and mentoring junior developers while continuing to deepen my engineering domain knowledge.",
        "status": "unread",
        "is_starred": 0,
        "repeat_count": 3
    },
    {
        "category": "HR",
        "question": "Why do you want to join our company?",
        "answer": "I admire your company's innovative product ecosystem and engineering culture. My skills directly align with your stack, and I am excited about contributing to impactful features for your users.",
        "status": "unread",
        "is_starred": 0,
        "repeat_count": 3
    },
    {
        "category": "Python",
        "question": "What is the GIL or Global Interpreter Lock in Python?",
        "answer": "The Global Interpreter Lock is a mutex in CPython that prevents multiple native threads from executing Python bytecode simultaneously. It ensures thread safety for memory management, but limits CPU-bound multi-threading, where multi-processing or asynchronous execution should be used instead.",
        "status": "needs_practice",
        "is_starred": 1,
        "repeat_count": 3
    },
    {
        "category": "Python",
        "question": "What is the difference between list and tuple in Python?",
        "answer": "Lists are mutable sequences created with square brackets, allowing items to be added or modified. Tuples are immutable sequences created with parentheses, consuming less memory and providing hashability for use as dictionary keys.",
        "status": "needs_practice",
        "is_starred": 0,
        "repeat_count": 3
    },
    {
        "category": "Python",
        "question": "Explain Python decorators and how they work.",
        "answer": "A decorator is a function that takes another function as an argument, extends or modifies its behavior without changing its source code, and returns a new callable function. They are commonly used for logging, timing, authentication, and caching.",
        "status": "unread",
        "is_starred": 1,
        "repeat_count": 3
    },
    {
        "category": "Technical",
        "question": "What is the difference between SQL and NoSQL databases?",
        "answer": "SQL databases are relational, table-based, and use predefined schemas with strong ACID transactions. NoSQL databases are non-relational, document, key-value, or graph-based, offering flexible schemas and high horizontal scalability for unstructured data.",
        "status": "needs_practice",
        "is_starred": 1,
        "repeat_count": 3
    },
    {
        "category": "Technical",
        "question": "Explain Object-Oriented Programming principles.",
        "answer": "OOP relies on four main pillars: Encapsulation, which bundles data and methods while hiding internal state; Abstraction, which exposes only essential details; Inheritance, which allows child classes to reuse parent properties; and Polymorphism, which enables uniform interfaces across different object types.",
        "status": "unread",
        "is_starred": 0,
        "repeat_count": 3
    },
    {
        "category": "Technical",
        "question": "What is RESTful API architecture?",
        "answer": "REST is an architectural style for network applications based on stateless client-server communication using standard HTTP methods like GET, POST, PUT, and DELETE, with responses formatted as JSON or XML.",
        "status": "unread",
        "is_starred": 0,
        "repeat_count": 3
    },
    {
        "category": "Behavioral",
        "question": "Describe a difficult conflict with a team member and how you resolved it.",
        "answer": "Using the STAR method: I faced a disagreement on system design. I scheduled an offline discussion, presented data-driven pros and cons for both approaches, actively listened to their architectural concerns, and reached a consensus that combined the best aspects of both designs.",
        "status": "needs_practice",
        "is_starred": 1,
        "repeat_count": 3
    },
    {
        "category": "Behavioral",
        "question": "How do you handle strict deadlines under pressure?",
        "answer": "I prioritize tasks using the 80-20 rule, communicate early with project managers if trade-offs are required, break complex deliverables into manageable daily milestones, and eliminate non-essential distractions.",
        "status": "unread",
        "is_starred": 0,
        "repeat_count": 3
    },
    {
        "category": "System Design",
        "question": "How would you design a rate limiter for an API?",
        "answer": "I would use a Token Bucket or Sliding Window Counter algorithm backed by an in-memory cache like Redis. When a request arrives, the service checks request counts against client IP or API key and responds with HTTP 429 if the limit is exceeded.",
        "status": "needs_practice",
        "is_starred": 1,
        "repeat_count": 3
    },
    {
        "category": "Web Development",
        "question": "What is the Event Loop in JavaScript?",
        "answer": "The JavaScript event loop manages asynchronous execution by pushing synchronous code onto the call stack, delegating web APIs or microtasks, and moving callback functions from the task queue back onto the call stack when it becomes empty.",
        "status": "unread",
        "is_starred": 0,
        "repeat_count": 3
    }
]

def populate_sample_data_if_empty(db):
    """Populates the database if no Q&A items exist yet."""
    stats = db.get_stats()
    if stats["total"] == 0:
        for item in SAMPLE_QA_ITEMS:
            db.add_qa(
                question=item["question"],
                answer=item["answer"],
                category=item["category"],
                status=item["status"],
                is_starred=item["is_starred"],
                repeat_count=item["repeat_count"]
            )
        print(f"Populated {len(SAMPLE_QA_ITEMS)} sample interview Q&A items into database.")
        return True
    return False
