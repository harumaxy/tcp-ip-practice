# udp server
# -u = udp
# -l = listen (run as server)
# -n = IPをDNSで名前解決させない
# -v = verbose
nc -ulnv 127.0.0.1 54321


# udp も tcpdump で見れる(名前変えたほうが良くね)
# sudo tcpdump -i lo -tnlA "udp and port 54321"

# udp client (デフォルトはクライアントモード)
nc -u 127.0.0.1 54321
