# Use lightweight Python base image
FROM python:3.11-alpine

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN apk add --no-cache build-base libffi-dev openssl-dev
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy all other project files
COPY . .

# Expose app port
EXPOSE 3000

# Run the app
CMD ["python", "app.py"]
