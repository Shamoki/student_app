const express = require("express");
const router = express.Router();
const Flashcard = require("../models/Flashcard");

// ✅ Get all flashcards (optionally filter by unit and/or topic, with pagination)
router.get("/", async (req, res) => {
  try {
    const { unit, topic, page = 1, limit = 20 } = req.query;

    const filter = {};
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

// ✅ Get all distinct units
router.get("/units", async (req, res) => {
  try {
    const units = await Flashcard.distinct("unit");
    res.json(units);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

// ✅ Get all topics in a specific unit
router.get("/topics/:unit", async (req, res) => {
  try {
    const topics = await Flashcard.distinct("topic", { unit: req.params.unit });
    res.json(topics);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

// ✅ Add a new flashcard
router.post("/", async (req, res) => {
  const { unit, topic, question, answer } = req.body;

  if (!unit || !topic || !question || !answer) {
    return res.status(400).json({ error: "Unit, topic, question, and answer are required" });
  }

  try {
    const newFlashcard = new Flashcard({ unit, topic, question, answer });
    await newFlashcard.save();
    res.status(201).json(newFlashcard);
  } catch (err) {
    res.status(500).json({ error: "Error saving flashcard" });
  }
});

// ✅ Delete a flashcard by ID
router.delete("/:id", async (req, res) => {
  try {
    const result = await Flashcard.findByIdAndDelete(req.params.id);

    if (!result) {
      return res.status(404).json({ error: "Flashcard not found" });
    }

    res.status(200).json({ message: "Flashcard deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: "Error deleting flashcard" });
  }
});

module.exports = router;
