import "./App.css";

import CustomNavbar from "./components/navbar/navbar";
import { BrowserRouter as Router } from "react-router-dom";
import MyRoutes from "./routers/routes";
import { useEffect } from "react";

function App() {
  useEffect(() => {
    localStorage.setItem("theme", "light");
    let theme = localStorage.getItem("theme");
    console.log("theme: " + theme);
    const prefer = window.matchMedia("(prefers-color-scheme)");
    console.log("prefer: " + prefer);
    if (
      theme === "dark" ||
      (!("theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      document.body.classList.add("dark");
    } else {
      document.body.classList.remove("dark");
    }

    // Whenever the user explicitly chooses light mode
    theme = "light";

    // Whenever the user explicitly chooses dark mode
    theme = "dark";

    // Whenever the user explicitly chooses to respect the OS preference
    localStorage.removeItem("theme");
  }, []);
  return (
    <Router>
      <CustomNavbar />
      <MyRoutes />
    </Router>
  );
}

export default App;
