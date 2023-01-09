su

ip netns add lan
ip netns add router
ip netns add wan

ip link add lan-veth0 type veth peer name gw-veth0
ip link add wan-veth0 type veth peer name gw-veth1

ip link set lan-veth0 netns lan
ip link set gw-veth0 netns router
ip link set gw-veth1 netns router
ip link set wan-veth0 netns wan

ip netns exec lan ip link set lan-veth0 up
ip netns exec router ip link set gw-veth0 up
ip netns exec router ip link set gw-veth1 up
ip netns exec wan ip link set wan-veth0 up

# set ip address
ip netns exec lan ip address add 192.0.2.1/24 dev lan-veth0
ip netns exec wan ip address add 203.0.113.1/24 dev wan-veth0
ip netns exec router ip address add 192.0.2.254/24 dev gw-veth0
ip netns exec router ip address add 203.0.113.254/24 dev gw-veth1
# set rotuer mode
ip netns exec router sysctl net.ipv4.ip_forward=1
# routing default to router
ip netns exec lan ip route add default via 192.0.2.254
ip netns exec wan ip route add default via 203.0.113.254

# iptables コマンド : Linux にあるいろんなIPプロトコル関連のテーブルに関する操作を行うコマンド
#  -t nat : NATテーブルを指定
#  -L : 現在のルールを表示

# 現在のNATテーブルルールを表示
ip netns exec router iptables -t nat -L

# Source NAT demo
# NATテーブルルールの追加
ip netns exec router iptables -t nat \
  -A POSTROUTING \
  -s 192.0.2.0/24 \
  -o gw-veth1 \
  -j MASQUERADE

# POSTROUTING チェインに
# 192.0.2.0/24 をソースとする
# gw-veth1 から出力される通信に対して
# MASQUERADEルールを適用する
# MASQUERADE = Source NAT 処理の実装につけられた名前

# sudo ip netns exec lan ping 203.0.113.1
# router -> wan への通信の Out は、router がSourceになる
# lan <- router への通信の In は Destination が lan になる


# Destination NAT demo

ip netns exec router iptables -t nat \
  -A PREROUTING \
  -p tcp \
  --dport 54321 \
  -d 203.0.113.254 \
  -j DNAT \
  --to-destination 192.0.2.1

# PREROUTING チェインに
# TCP で
# ルーターのグローバルアドレス(203.0.113.254) の 54321 port を宛先とするパケットに
# DNATルールを適用する
# 変換先はプライベートアドレス 192.0.2.1

# server
# sudo ip netns exec lan nc -lnv 54321
# client
# sudo ip netns exec wan nc 203.0.113.254 54321
# tcpdump
