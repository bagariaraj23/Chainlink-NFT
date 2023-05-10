import "./App.css";

import CustomNavbar from "./components/navbar/navbar";
import { BrowserRouter as Router } from "react-router-dom";
import MyRoutes from "./routers/routes";

function App() {
  return (
    <Router>
      <CustomNavbar />
      <MyRoutes />
    </Router>
  );
}

export default App;
