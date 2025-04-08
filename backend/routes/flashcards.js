const express = require("express");
const router = express.Router();
const Flashcard = require("../models/Flashcard");
const authenticateToken = require("../middlewares/authenticateToken");

// 🔒 All routes below this require a valid token with role
router.use(authenticateToken);

// ✅ Get all flashcards (filtered by user, unit, topic, pagination)
router.get("/", async (req, res) => {
  try {
    const { unit, topic, page = 1, limit = 20 } = req.query;

    const filter = { user: req.user.userId }; // Only this user's flashcards
    if (unit) filter.unit = unit;
    if (topic) filter.topic = topic;

    const flashcards = await Flashcard.find(filter)
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    res.json(flashcards);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

// ✅ Get all distinct units (user-specific)
router.get("/units", async (req, res) => {
  try {
    const units = await Flashcard.distinct("unit", { user: req.user.userId });
    res.json(units);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

// ✅ Get all topics in a unit (user-specific)
router.get("/topics/:unit", async (req, res) => {
  try {
    const topics = await Flashcard.distinct("topic", {
      user: req.user.userId,
      unit: req.params.unit,
    });
    res.json(topics);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

// ✅ Add a new flashcard (only for teachers)
router.post("/", async (req, res) => {
  if (req.user.role !== "teacher") {
    return res.status(403).json({ error: "Only teachers can create flashcards" });
  }

  const { unit, topic, question, answer } = req.body;

  if (!unit || !topic || !question || !answer) {
    return res.status(400).json({ error: "Unit, topic, question, and answer are required" });
  }

  try {
    const newFlashcard = new Flashcard({
      unit,
      topic,
      question,
      answer,
      user: req.user.userId, // Attach user ID
    });

    await newFlashcard.save();
    res.status(201).json(newFlashcard);
  } catch (err) {
    res.status(500).json({ error: "Error saving flashcard" });
  }
});

// ✅ Delete a flashcard by ID (only for teachers, must belong to them)
router.delete("/:id", async (req, res) => {
  if (req.user.role !== "teacher") {
    return res.status(403).json({ error: "Only teachers can delete flashcards" });
  }

  try {
    const result = await Flashcard.findOneAndDelete({
      _id: req.params.id,
      user: req.user.userId,
    });

    if (!result) {
      return res.status(404).json({ error: "Flashcard not found or not yours" });
    }

    res.status(200).json({ message: "Flashcard deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: "Error deleting flashcard" });
  }
});

module.exports = router;
