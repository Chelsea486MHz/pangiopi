# Restart Gunicorn every 950-1050 requests
# May mitigate memory leak attacks
max_requests = 1000
max_requests_jitter = 50

bind = '0.0.0.0:5000'
timeout = 5

workers = 1  # LZMA is NOT thread-safe!
