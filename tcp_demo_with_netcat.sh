# server
nc -lnv 127.0.0.1 54321

# tcpdump -i lo -tnlA "tcp and port 54321"

# client
nc 127.0.0.1 54321