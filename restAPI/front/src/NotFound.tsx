import React from "react";

const NotFound: React.FC = () => {
  return (
    <div
      style={{
        textAlign: "center",
        paddingTop: "100px",
        fontFamily: "sans-serif",
      }}
    >
      <h1 style={{ fontSize: "3rem", color: "#ff6b6b" }}>404</h1>
      <p style={{ fontSize: "1.5rem" }}>페이지를 찾을 수 없습니다.</p>
      <a href="/" style={{ color: "#007bff", textDecoration: "underline" }}>
        홈으로 돌아가기
      </a>
    </div>
  );
};

export default NotFound;
