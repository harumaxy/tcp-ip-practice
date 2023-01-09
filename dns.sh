# DNSはデフォルトで UDP 53 port を使う
sudo tcpdump -tnl -i any "udp and port 53"

# enp0s1 Out IP 192.168.64.2.45723 > 8.8.8.8.53: 42564+ [1au] A? example.org. (52)
# enp0s1 In  IP 8.8.8.8.53 > 192.168.64.2.45723: 42564$ 1/0/1 A 93.184.216.34 (56)
# ペイロードも単純で、 A? は Aレコードをクエリする、その後にドメイン名を書く

# レコードの種類
# CNAME = ドメインの別名
# AAAA = IpV6アドレス
# TXT = 任意の文字列
# DNSリクエストの基本は、Recodrd?+引数

dig +short @8.8.8.8 example.org
# 93.184.216.34