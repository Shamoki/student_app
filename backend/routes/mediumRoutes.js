const express = require("express");
const axios = require("axios");
const { parseString } = require("xml2js");

const router = express.Router();

router.get("/articles", async (req, res) => {
  const { interests } = req.query; // Fetch interests from query params

  if (!interests) {
    return res.status(400).json({ error: "No interests provided" });
  }

  const interestArray = interests.split(","); // Convert query string into an array
  let allArticles = [];

  try {
    for (let topic of interestArray) {
      let formattedTopic = topic.trim().replace(/\s+/g, "-"); // Convert spaces to dashes
      let rssFeedUrl = `https://medium.com/feed/tag/${formattedTopic}`;

      try {
        const response = await axios.get(rssFeedUrl);

        parseString(response.data, (err, result) => {
          if (!err) {
            let articles = result.rss.channel[0].item.map((item) => ({
              title: item.title[0],
              link: item.link[0],
              pubDate: item.pubDate[0],
              description: item.description ? item.description[0] : "No description available",
            }));

            allArticles.push(...articles);
          }
        });
      } catch (fetchError) {
        console.warn(`Failed to fetch articles for topic: ${formattedTopic}`);
      }
    }

    // Sort articles by publication date (most recent first)
    allArticles.sort((a, b) => new Date(b.pubDate) - new Date(a.pubDate));

    res.json({ items: allArticles.slice(0, 15) }); // Limit to 15 articles
  } catch (error) {
    console.error("Error fetching Medium RSS feed:", error);
    res.status(500).json({ error: "Failed to fetch articles" });
  }
});

module.exports = router;
