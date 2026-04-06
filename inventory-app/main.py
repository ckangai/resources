import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def process_inventory():
    """Endpoint that returns a static string."""
    return "Inventory processing complete\n\n"

@app.route("/crash")
def crash_app():
    """This route intentionally raises a ValueError to test error handling."""
    raise ValueError("Simulating a crash with a ValueError")

@app.route("/kill")
def kill_app():
    """This route intentionally causes a division by zero error."""
    # This will raise a ZeroDivisionError
    result = 1 / 0
    return f"This message will not be seen. Result: {result}"


if __name__ == "__main__":
    # Cloud Run provides the PORT environment variable.
    port = int(os.environ.get("PORT", 8080))
    app.run(debug=True, host="0.0.0.0", port=port)