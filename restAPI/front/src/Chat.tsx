import React, { useEffect, useRef, useState } from "react";

const WS_URL = "ws://localhost:4000/ws";

const Chat: React.FC = () => {
  const [messages, setMessages] = useState<string[]>([]);
  const [input, setInput] = useState("");
  const socketRef = useRef<WebSocket | null>(null);

  useEffect(() => {
    const socket = new WebSocket(WS_URL);
    socketRef.current = socket;

    socket.onopen = () => {
      console.log("✅ WebSocket 연결됨");
      socket.send("안녕하세요! 채팅에 오신 것을 환영합니다.");
    };

    socket.onmessage = (event) => {
      setMessages((prev) => [...prev, `📨 ${event.data}`]);
    };

    socket.onclose = () => {
      console.log("❌ WebSocket 연결 종료");
    };
    socket.onerror = (e) => console.error("⚠️ 에러");

    return () => {
      socket.close();
    };
  }, []);

  const sendMessage = () => {
    if (socketRef.current && input.trim()) {
      socketRef.current.send(input);
      setMessages((prev) => [...prev, `🧑‍💻 ${input}`]);
      setInput("");
    }
  };

  return (
    <div style={{ padding: "1rem", maxWidth: "600px", margin: "auto" }}>
      <h2>💬 실시간 채팅</h2>
      <div
        style={{
          border: "1px solid #ccc",
          padding: "1rem",
          height: "300px",
          overflowY: "scroll",
          marginBottom: "1rem",
          background: "#fafafa",
        }}
      >
        {messages.map((msg, i) => (
          <div key={i}>{msg}</div>
        ))}
      </div>

      <input
        type="text"
        value={input}
        onChange={(e) => setInput(e.target.value)}
        onKeyDown={(e) => e.key === "Enter" && sendMessage()}
        style={{ width: "80%", marginRight: "1rem" }}
        placeholder="메시지를 입력하세요"
      />
      <button onClick={sendMessage}>전송</button>
    </div>
  );
};

export default Chat;
