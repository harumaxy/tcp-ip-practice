# 構成
# サブネット
# - 192.0.2.0/24 : ns1-veth0 <-> gw1-veth0
# - 203.0.113.0.24: gw1-veth1 <-> gw2-veth0
# - 198.51.100.0/24: gw2-veth1 <-> ns2-veth0
# ns
# - ns1
# - ns2
# router
# - router1
# - router2
# ns1 <-> router1 <-> router2 <-> ns2



# set defult su pass
# sudo passwd

su

# via (preposition) = ... を経由して、...を通って

# add ... で複数続けても、最初の一つしか作成されない
ip netns add ns1
ip netns add ns2
ip netns add router1
ip netns add router2

# link : ns1 -> router1 -> router2 -> ns2
ip link add ns1-veth0 type veth peer name gw1-veth0
ip link add gw1-veth1 type veth peer name gw2-veth0
ip link add gw2-veth1 type veth peer name ns2-veth0

ip link set ns1-veth0 netns ns1
ip link set ns2-veth0 netns ns2
ip link set gw1-veth0 netns router1
ip link set gw1-veth1 netns router1
ip link set gw2-veth0 netns router2
ip link set gw2-veth1 netns router2

# set ip address
ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0
ip netns exec router1 ip address add 192.0.2.254/24 dev gw1-veth0
ip netns exec router1 ip address add 203.0.113.1/24 dev gw1-veth1
ip netns exec router2 ip address add 203.0.113.2/24 dev gw2-veth0
ip netns exec router2 ip address add 198.51.100.254/24 dev gw2-veth1
ip netns exec ns2 ip address add 198.51.100.1/24 dev ns2-veth0

# set MAC address
ip netns exec ns1 ip link set dev ns1-veth0 address 00:00:5e:00:53:01
ip netns exec ns2 ip link set dev ns2-veth0 address 00:00:5e:00:53:02
ip netns exec router1 ip link set dev gw1-veth0 address 00:00:5e:00:53:03
ip netns exec router1 ip link set dev gw1-veth1 address 00:00:5e:00:53:04
ip netns exec router2 ip link set dev gw2-veth0 address 00:00:5e:00:53:05
ip netns exec router2 ip link set dev gw2-veth1 address 00:00:5e:00:53:06

# set status UP for all interfaces
ip netns exec ns1 ip link set ns1-veth0 up
ip netns exec router1 ip link set gw1-veth0 up
ip netns exec router1 ip link set gw1-veth1 up
ip netns exec router2 ip link set gw2-veth0 up
ip netns exec router2 ip link set gw2-veth1 up
ip netns exec ns2 ip link set ns2-veth0 up

# set ns1/ns2 routing table
ip netns exec ns1 ip route add default via 192.0.2.254
ip netns exec ns2 ip route add default via 198.51.100.254

# set router1/router2 routing table 
ip netns exec router1 ip route add 198.51.100.0/24 via 203.0.113.2
ip netns exec router2 ip route add 192.0.2.0/24 via 203.0.113.1

# set router ns as IPv4 router
ip netns exec router1 sysctl net.ipv4.ip_forward=1
ip netns exec router2 sysctl net.ipv4.ip_forward=1




# ip netns exec ns1 tcpdump -i ns1-veth0 icmp
# ip -a netns del