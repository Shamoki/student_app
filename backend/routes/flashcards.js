const express = require("express");
const router = express.Router();
const Flashcard = require("../models/Flashcard");
const authenticateToken = require("../middlewares/authenticateToken");

router.use(authenticateToken);

// ✅ Get flashcards (user-specific, filter by unitId and topic)
router.get("/", async (req, res) => {
  try {
    const { unitId, topic, page = 1, limit = 20 } = req.query;

    const filter = { user: req.user.userId };
    if (unitId) filter.unit = unitId;
    if (topic) filter.topic = topic;

    const flashcards = await Flashcard.find(filter)
      .populate("unit") // Optional: fetch unit details
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    res.json(flashcards);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

// ✅ Add a new flashcard (teachers only)
router.post("/", async (req, res) => {
  if (req.user.role !== "teacher") {
    return res.status(403).json({ error: "Only teachers can create flashcards" });
  }

  const { unitId, topic, question, answer } = req.body;

  if (!unitId || !topic || !question || !answer) {
    return res.status(400).json({ error: "All fields are required" });
  }

  try {
    const newFlashcard = new Flashcard({
      unit: unitId,
      topic,
      question,
      answer,
      user: req.user.userId,
    });

    await newFlashcard.save();
    res.status(201).json(newFlashcard);
  } catch (err) {
    res.status(500).json({ error: "Error saving flashcard" });
  }
});

// ✅ Delete a specific flashcard (teachers only)
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
