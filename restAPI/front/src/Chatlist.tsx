import { NavLink } from "react-router-dom";
import "./Chatlist.css";

const rooms = [
  { id: "1", name: "💬 일반 채팅방" },
  { id: "2", name: "🔥 익명 토론방" },
  { id: "3", name: "🎮 게임 채팅방" },
  { id: "4", name: "📚 공부 채팅방" },
  { id: "5", name: "😄 수다 채팅방" },
];

const ChatList = () => {
  return (
    <div className="chat-list-container">
      <h1 className="chat-list-title">채팅방 목록</h1>
      <ul className="chat-list">
        {rooms.map((room) => (
          <li key={room.id}>
            <NavLink to={`/chat/${room.id}`} className="chat-link">
              {room.name}
            </NavLink>
          </li>
          
        ))}
        <li>
          <NavLink to={'/'} className={"chat-link"}>
            홈으로 돌아가기 
          </NavLink>
        </li>
      </ul>
    </div>
  );
};

export default ChatList;
