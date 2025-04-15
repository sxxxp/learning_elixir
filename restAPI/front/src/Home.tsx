// src/pages/Home.tsx
import { NavLink } from "react-router-dom";
import { useCookies } from "react-cookie";
import "./Home.css";
import { useEffect, useState } from "react";

const Home = () => {
  const [cookies, setCookie, removeCookie] = useCookies(["nickname"]);
  const [name, setName] = useState<string>(cookies.nickname);
  const [inputValue, setInputValue] = useState<string>("");
  const setNickname = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (inputValue) {
      setCookie("nickname", inputValue, { path: "/" });
      setName(inputValue);
    }
  };
  useEffect(() => {}, [name]);
  return ( 
    <div className="home-container">
      <h1 className="home-title">홈 화면</h1>
      <h2>닉네임: {name}</h2>
      <form onSubmit={setNickname}>
        <input
          type="text"
          value={inputValue}
          onChange={(e) => setInputValue(e.currentTarget.value)}
          placeholder="닉네임 설정"
          className="nickname-input"
        />
      </form>

      <NavLink to={"/chat"} className="chat-button">
        채팅하러가기
      </NavLink>
    </div>
  );
};

export default Home;
