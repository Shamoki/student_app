const express = require('express');
const router = express.Router();
const Topic = require('../models/Topic');

// 📥 Create a new topic
router.post('/', async (req, res) => {
  const { name, unit } = req.body;

  if (!name || !unit) {
    return res.status(400).json({ error: "Name and unit are required" });
  }

  try {
    const existing = await Topic.findOne({ name, unit });
    if (existing) {
      return res.status(409).json({ error: "Topic already exists for this unit" });
    }

    const newTopic = new Topic({ name, unit });
    await newTopic.save();
    res.status(201).json(newTopic);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

// 📤 Get all topics for a specific unit
router.get('/:unit', async (req, res) => {
  try {
    const topics = await Topic.find({ unit: req.params.unit }).sort({ name: 1 });
    res.json(topics.map(t => t.name));
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
