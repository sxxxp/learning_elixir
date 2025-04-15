import React, { useEffect, useRef, useState } from "react";
import { useCookies } from "react-cookie";
import { useNavigate, useParams } from "react-router-dom";

const rooms = [
  { id: "1", name: "💬 일반 채팅방" },
  { id: "2", name: "🔥 익명 토론방" },
  { id: "3", name: "🎮 게임 채팅방" },
  { id: "4", name: "📚 공부 채팅방" },
  { id: "5", name: "😄 수다 채팅방" },
];
const Chat: React.FC = () => {
  const [messages, setMessages] = useState<string[]>([]);
  const [input, setInput] = useState("");
  const [cookie, setCookie, removeCookie] = useCookies(["nickname"]);
  const user = cookie.nickname || "게스트";
  const scrollRef = useRef<HTMLDivElement>(null);
  const { id } = useParams();
  const socketRef = useRef<WebSocket | null>(null);
  let navigate = useNavigate();
  const room = rooms.find((r) => r.id === id);
  const WS_URL = "ws://localhost:4000/ws/" + id;
  if (!room) {
    navigate("/404");
  }
  const getTime = () => {
    const date = new Date();
    return `${date.getHours()}:${date.getMinutes()}`;
  };

  type method = "join" | "exit" | "send";

  const messageFormat = (type: method, user: string, message: string) => {
    return `%Struct.Chat{type: :${type}, user: "${user}", message: "${message}", time: "${getTime()}"}`;
  };
  useEffect(() => {
    const socket = new WebSocket(WS_URL);
    socketRef.current = socket;
    if(scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
    socket.onopen = () => {
      console.log("✅ WebSocket 연결됨");
      socket.send(messageFormat("join", user, "입장"));
    };

    socket.onmessage = (event) => {
      console.log(event.data);
      event.data.split("\n").forEach((msg: string) => {
        setMessages((prev) => [...prev, `${msg}`]);
      });
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
      socketRef.current.send(messageFormat("send", user, input));
      setInput("");
    } else if (!socketRef.current) {
      alert("서버와 연결이 끊겼습니다.");
    }
  };
  const exitChat = () => {
    if (socketRef.current) {
      socketRef.current.send(messageFormat("exit", user, "퇴장"));
      socketRef.current.close();
      socketRef.current = null;
    }

    setMessages((prev) => [...prev, "👋 유저님이 채팅을 떠났습니다."]);
    navigate("/chat");
  };
  return (
    <div style={{ padding: "1rem", maxWidth: "800px", margin: "auto" }}>
      <h2>{room ? room?.name : "정보를 찾지 못했습니다."}</h2>
      <div
        style={{
          border: "1px solid #ccc",
          padding: "1rem",
          height: "300px",
          overflowY: "scroll",
          marginBottom: "1rem",
          background: "#fafafa",
        }}
        ref={scrollRef}
      >
        {messages.map((msg, i) => (
          <div key={i}>{msg}</div>
        ))}
      </div>
      <div style={{ display: "inline" }}>
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && sendMessage()}
          style={{ width: "80%", marginRight: "1rem" }}
          placeholder="메시지를 입력하세요"
        />
        <button onClick={sendMessage} style={{ marginRight: "15px" }}>
          전송
        </button>
        <button onClick={exitChat}>나가기</button>
      </div>
    </div>
  );
};

export default Chat;
