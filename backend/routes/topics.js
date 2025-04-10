const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const Topic = require('../models/Topic');
const authenticateToken = require('../middlewares/authenticateToken');

// 🔒 Protect all topic routes
router.use(authenticateToken);

// 📥 Create a new topic (teachers only)
router.post('/', async (req, res) => {
  const { name, unit } = req.body;
  const userId = req.user.userId;

  if (req.user.role !== 'teacher') {
    return res.status(403).json({ error: "Only teachers can create topics" });
  }

  if (!name || !unit) {
    return res.status(400).json({ error: "Name and unit ID are required" });
  }

  try {
    const unitObjectId = new mongoose.Types.ObjectId(unit);

    const existing = await Topic.findOne({ name, unit: unitObjectId, user: userId });
    if (existing) {
      return res.status(409).json({ error: "Topic already exists for this unit" });
    }

    const newTopic = new Topic({ name, unit: unitObjectId, user: userId });
    await newTopic.save();

    res.status(201).json(newTopic);
  } catch (err) {
    console.error("Error creating topic:", err.message);
    res.status(500).json({ error: "Server error" });
  }
});

// 📤 Get all topics for a unit ID (visible to both teachers and students)
router.get('/:unit', async (req, res) => {
  const unitId = req.params.unit;

  try {
    const unitObjectId = new mongoose.Types.ObjectId(unitId);

    const topics = await Topic.find({ unit: unitObjectId }).sort({ name: 1 });
    res.json(topics.map(t => t.name));
  } catch (err) {
    console.error("Error fetching topics:", err.message);
    res.status(500).json({ error: "Server error" });
  }
});

// 📚 Grouped topics for dashboard (optional)
router.get('/', async (req, res) => {
  const userId = req.user.userId;

  try {
    const topics = await Topic.find({ user: userId });

    const grouped = topics.reduce((acc, topic) => {
      if (!topic.unit) return acc;

      const unitId = topic.unit.toString();
      if (!acc[unitId]) {
        acc[unitId] = [];
      }
      acc[unitId].push(topic.name);
      return acc;
    }, {});

    res.json(grouped);
  } catch (err) {
    console.error("Error grouping topics:", err.message);
    res.status(500).json({ error: "Server error" });
  }
});

// 🗑️ Delete a topic (teachers only)
router.delete('/:unit/:name', async (req, res) => {
  const { unit, name } = req.params;
  const userId = req.user.userId;

  if (req.user.role !== 'teacher') {
    return res.status(403).json({ error: "Only teachers can delete topics" });
  }

  try {
    const unitObjectId = new mongoose.Types.ObjectId(unit);

    const deleted = await Topic.findOneAndDelete({ unit: unitObjectId, name, user: userId });

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
