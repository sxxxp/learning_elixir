import React from "react";
import Chat from "./Chat";
import "./App.css";
import { Route, BrowserRouter, Routes } from "react-router-dom";
import NotFound from "./NotFound";
import Home from "./Home";
import ChatList from "./Chatlist";
import { CookiesProvider } from "react-cookie";

function App() {
  return (
    <CookiesProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/chat" element={<ChatList />} />
          <Route path="/chat/:id" element={<Chat />} />

          <Route path="*" element={<NotFound />} />
        </Routes>
      </BrowserRouter>
    </CookiesProvider>
  );
}

export default App;
