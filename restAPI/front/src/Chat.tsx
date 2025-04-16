import React, { useEffect, useRef, useState } from "react";
import { Cookies, useCookies } from "react-cookie";
import { useBeforeUnload, useNavigate, useParams } from "react-router-dom";
import "./Chat.css";

const rooms = [
  { id: "1", name: "💬 일반 채팅방" },
  { id: "2", name: "🔥 익명 토론방" },
  { id: "3", name: "🎮 게임 채팅방" },
  { id: "4", name: "📚 공부 채팅방" },
  { id: "5", name: "😄 수다 채팅방" },
];

interface Message {
  text: string;
  user: string;
  time: string;
}

const ChatMessage = ({ message }: { message: Message }) => {
  const cookie = new Cookies();
  const isOwn = message.user === cookie.get("nickname");

  if (message.user === "[system]") {
    return (
      <div className="system-message">
        <span>
          {message.text} <span className="timestamp">{message.time}</span>
        </span>
      </div>
    );
  }
  return (
    <div className={`chat-message ${isOwn ? "own" : "other"}`}>
      <img
        src={
          isOwn
            ? "https://randomuser.me/api/portraits/men/32.jpg"
            : "https://randomuser.me/api/portraits/women/79.jpg"
        }
        alt="avatar"
        className="avatar"
      />
      <div className="message-content">
        <div className="message-info">
          <span className="username">{message.user}</span>
          <span className="timestamp">{message.time}</span>
        </div>
        <div className="message-bubble">{message.text}</div>
      </div>
    </div>
  );
};

const Chat: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [cookie] = useCookies(["nickname"]);
  const user = cookie.nickname || "게스트";
  const scrollRef = useRef<HTMLDivElement>(null);
  const { id } = useParams();
  const socketRef = useRef<WebSocket | null>(null);
  const navigate = useNavigate();

  const room = rooms.find((r) => r.id === id);
  const WS_URL = "ws://localhost:4000/ws/" + id;

  if (!room) {
    navigate("/404");
  }

  const unloadFunc = (e: BeforeUnloadEvent) => {
    e.preventDefault();
  };
  useBeforeUnload(unloadFunc);
  const getTime = () => {
    const date = new Date();
    const h = date.getHours().toString().padStart(2, "0");
    const m = date.getMinutes().toString().padStart(2, "0");
    return `${h}:${m}`;
  };

  type Method = "join" | "exit" | "send";

  const messageFormat = (type: Method, user: string, message: string) => {
    return `%Struct.Chat{type: :${type}, user: "${user}", message: "${message}", time: "${getTime()}"}`;
  };

  useEffect(() => {
    if (socketRef.current) {
      console.log("🟡 기존 WebSocket 연결이 존재합니다.");
      return;
    }
    const socket = new WebSocket(WS_URL);
    socketRef.current = socket;

    socket.onopen = () => {
      console.log("✅ WebSocket 연결됨");
      socket.send(messageFormat("join", user, "입장"));
    };

    socket.onmessage = (event) => {
      event.data.split("\n").forEach((msg: string) => {
        let sendmessage = "",
          sendtime = "",
          senduser = "";
        if (msg.startsWith("[입장]") || msg.startsWith("[퇴장]")) {
          [sendmessage, sendtime] = msg.split("-");
          senduser = "[system]";
        } else {
          let [content, time] = msg.split("-");
          let [u, m] = content.split(":");
          senduser = u;
          sendmessage = m;
          sendtime = time;
        }
        setMessages((prev) => [
          ...prev,
          { text: sendmessage, user: senduser, time: sendtime },
        ]);
      });
    };

    socket.onclose = () => {
      console.log("❌ WebSocket 연결 종료");
    };

    socket.onerror = (e) => console.error("⚠️ 에러");

    return () => {
      socket.close();
      socketRef.current = null;

    };
  }, []);

  // 스크롤 자동 아래로
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const sendMessage = () => {
    if (!socketRef.current) {
      alert("서버와 연결이 끊겼습니다.");
      return;
    }
    if (input.trim()) {
      socketRef.current.send(messageFormat("send", user, input));
      setInput("");
    }
  };

  const exitChat = () => {
    if (socketRef.current) {
      socketRef.current.send(messageFormat("exit", user, "퇴장"));
      socketRef.current.close();
      socketRef.current = null;
    }

    setMessages((prev) => [
      ...prev,
      {
        text: "👋 유저님이 채팅을 떠났습니다.",
        user: "[system]",
        time: getTime(),
      },
    ]);
    navigate("/chat");
  };

  return (
    <div className="chat-room">
      <div className="chat-header">
        {room?.name}{" "}
        <button className="exit-button" onClick={exitChat}>
          나가기
        </button>
      </div>
      <div className="chat-body" ref={scrollRef}>
        {messages.map((msg, index) => (
          <ChatMessage key={index} message={msg} />
        ))}
      </div>
      <div className="chat-input">
        <input
          type="text"
          placeholder="메시지를 입력하세요"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && sendMessage()}
        />
        <button onClick={sendMessage}>전송</button>
      </div>
    </div>
  );
};

export default Chat;
