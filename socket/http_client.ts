const decorder = new TextDecoder();
const addr: Deno.ConnectOptions = {
  port: 80,
  hostname: "example.com",
  transport: "tcp",
};

async function sendMsg(sock: Deno.TcpConn, msg: Uint8Array): Promise<void> {
  let totalSentLen = 0;
  while (totalSentLen < msg.length) {
    const sentLen = await sock.write(msg.slice(totalSentLen));
    if (sentLen === 0) {
      throw new Error("socket connection broken");
    }
    totalSentLen += sentLen;
  }
}

async function* recvMsg(
  sock: Deno.TcpConn,
  chunkLen = 1024
): AsyncGenerator<string, null> {
  let buf = new Uint8Array(chunkLen);
  while (true) {
    const received = await sock.read(buf);
    if (received === null) {
      break;
    }
    yield decorder.decode(buf);
  }
  return null;
}

async function main() {
  const socket: Deno.TcpConn = await Deno.connect(addr);
  const reqBody = "GET / HTTP/1.1\nHost: example.com\n\n";
  const reqBytes = new TextEncoder().encode(reqBody);
  await sendMsg(socket, reqBytes);
  for await (const msg of recvMsg(socket)) {
    console.log(msg);
    if (!msg) {
      console.log("finished");
      break;
    }
  }
}

main();
