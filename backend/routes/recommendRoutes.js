const express = require('express');
const axios = require('axios');
const router = express.Router();

// POST /api/recommend/title
router.post('/recommend/title', async (req, res) => {
  try {
    const response = await axios.post('http://localhost:5001/recommend/title', {
      title: req.body.title
    });
    res.json(response.data);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Error getting title-based recommendations' });
  }
});

// POST /api/recommend/categories
router.post('/recommend/categories', async (req, res) => {
  try {
    const response = await axios.post('http://localhost:5001/recommend/categories', {
      topics: req.body.topics
    });
    res.json(response.data);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Error getting category-based recommendations' });
  }
});

module.exports = router;
