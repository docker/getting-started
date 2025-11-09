from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "✅ Docker Flask App is Running Successfully!"

if __name__ == '__main__':
    # Make sure it listens on all interfaces so Docker can expose it
    app.run(host='0.0.0.0', port=3000, debug=True)
