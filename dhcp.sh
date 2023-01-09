su

ip netns add server
ip netns add client

ip link ad s-veth0 type veth peer name c-veth0

ip link set s-veth0 netns server
ip link set c-veth0 netns client

ip netns exec server ip link set s-veth0 up
ip netns exec client ip link set c-veth0 up

ip netns exec server ip address add 192.0.2.254/24 dev s-veth0

exit


# start DHCP server
sudo ip netns exec server dnsmasq \
  --dhcp-range=192.0.2.100,192.0.2.200,255.255.255.0 \
  --interface=s-veth0 \
  --port 0 \
  --no-resolv \
  --no-daemon

# call from client
sudo ip netns exec client dhclient -d c-veth0

# ...
# bound to 192.0.2.105 -- renewal in 1782 seconds.
# client の Network interface c-veth0 に 192.0.2.105 のIPが割り当てられた