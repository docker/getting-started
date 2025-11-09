# Docker Flask Setup

A minimal Flask app containerized with Docker.  
This repository demonstrates how to build and run a small Flask app inside a Docker container — useful for quick local testing and learning Docker.

---

## 🧰 Contents
- `Dockerfile` — simple Dockerfile using `python:3.11-alpine`
- `app.py` — minimal Flask app
- `requirements.txt` — Python packages (Flask)

---

## 🚀 Quickstart (build & run)

### 1️⃣ Build the image
```bash
docker build -t getting-started:flask .


docker run -d -p 3000:3000 --name getting-started getting-started:flask

