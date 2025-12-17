import React from "react";
import tablet from "./tablet.png"; // Adjust path if needed
import "./Navbar.css";

const Navbar = () => {
  return (
    <nav className="navbar">
      <div className="logo-section">
        <img src={tablet} alt="Tablet logo" className="logo-img" />
        <span className="logo-text">morTodo</span>
      </div>
      <ul className="nav-links">
        <li>Home</li>
        <li>About Us</li>
        <li>Your Tasks</li>
      </ul>
    </nav>
  );
};

export default Navbar;
