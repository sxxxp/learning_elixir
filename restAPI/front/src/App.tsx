import React from "react";
import logo from "./logo.svg";
import Chat from "./Chat";
import "./App.css";
import { Route, BrowserRouter, Routes } from "react-router-dom";
import NotFound from "./NotFound";

function App() {
  return (
    <BrowserRouter>
    <Routes>
      <Route path="/chat" element={<Chat/>} />
      <Route path="*" element={<NotFound/>} />
    </Routes>
    </BrowserRouter>
  );
}

export default App;
