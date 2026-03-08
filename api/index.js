const express = require("express");
const fetch = require("node-fetch"); // npm install node-fetch@2
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 3000;

// Allow all origins (for Flutter web)
app.use(cors());

// Your SerpAPI key
const SERPAPI_KEY = "7d6b2edb99cdc8317ce069e516b4245ba1eccc5ab538b155fe5a4bd2cb7d38f8";

// Proxy endpoint
app.get("/search", async (req, res) => {
  const query = req.query.q;
  if (!query) return res.status(400).json({ error: "Missing query parameter q" });

  try {
    const serpUrl = `https://serpapi.com/search.json?engine=google&q=${encodeURIComponent(query)}&api_key=${SERPAPI_KEY}`;
    const response = await fetch(serpUrl);
    const data = await response.json();
    res.json(data);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "SerpAPI fetch failed" });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});