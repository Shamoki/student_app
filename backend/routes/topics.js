const express = require('express');
const router = express.Router();
const Topic = require('../models/Topic');
const authenticateToken = require('../middlewares/authenticateToken');

// 🔒 Protect all topic routes
router.use(authenticateToken);

// 📥 Create a new topic for a user
router.post('/', async (req, res) => {
  const { name, unit } = req.body;
  const userId = req.user.userId;

  if (!name || !unit) {
    return res.status(400).json({ error: "Name and unit are required" });
  }

  try {
    const existing = await Topic.findOne({ name, unit, user: userId });
    if (existing) {
      return res.status(409).json({ error: "Topic already exists for this unit" });
    }

    const newTopic = new Topic({ name, unit, user: userId });
    await newTopic.save();
    res.status(201).json(newTopic);
  } catch (err) {
    console.error("Error creating topic:", err.message);
    res.status(500).json({ error: "Server error" });
  }
});

// 📤 Get all topics for a unit (user-specific)
router.get('/:unit', async (req, res) => {
  const unit = req.params.unit;
  const userId = req.user.userId;

  try {
    const topics = await Topic.find({ unit, user: userId }).sort({ name: 1 });
    res.json(topics.map(t => t.name));
  } catch (err) {
    console.error("Error fetching topics:", err.message);
    res.status(500).json({ error: "Server error" });
  }
});

// 📚 Get topics grouped by unit (useful for landing pages)
router.get('/', async (req, res) => {
  const userId = req.user.userId;

  try {
    const topics = await Topic.find({ user: userId });

    const grouped = topics.reduce((acc, topic) => {
      if (!acc[topic.unit]) {
        acc[topic.unit] = [];
      }
      acc[topic.unit].push(topic.name);
      return acc;
    }, {});

    res.json(grouped);
  } catch (err) {
    console.error("Error grouping topics:", err.message);
    res.status(500).json({ error: "Server error" });
  }
});

// 🗑️ Optional: Delete a topic (user-specific)
router.delete('/:unit/:name', async (req, res) => {
  const { unit, name } = req.params;
  const userId = req.user.userId;

  try {
    const deleted = await Topic.findOneAndDelete({ unit, name, user: userId });

    if (!deleted) {
      return res.status(404).json({ error: "Topic not found" });
    }

    res.json({ message: "Topic deleted" });
  } catch (err) {
    console.error("Error deleting topic:", err.message);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
