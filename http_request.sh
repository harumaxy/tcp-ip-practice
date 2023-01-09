# sudo python3 -m http.server -b 127.0.0.1 80

# echo じゃなくて、ncで直接打ち込んでもOK
echo -en "GET / HTTP/1.0\r\n\r\n" | nc 127.0.0.1 80