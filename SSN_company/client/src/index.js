import ReactDOM from "react-dom/client";
import { Provider } from "react-redux";
import store from "./store/store";
import React from "react";
import App from "./App";

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
    <Provider store={store}>
        <App />
    </Provider>
);