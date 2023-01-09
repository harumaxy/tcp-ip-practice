// require --unstable flag

const addr: Deno.UdpListenOptions = {
  hostname: "127.0.0.1",
  port: 8000,
};

const datagramConn = Deno.listenDatagram({
  ...addr,
  transport: "udp",
});
const decorder = new TextDecoder();

console.log(`Listening on ${addr.hostname}:${addr.port}...`);

// echo server
for await (const [bytes, addr] of datagramConn) {
  (async () => {
    console.log(decorder.decode(bytes));
    console.log(addr);

    await datagramConn.send(bytes, addr);
  })();
}
