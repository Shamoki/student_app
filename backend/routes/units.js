const express = require("express");
const router = express.Router();
const Flashcard = require("../models/Flashcard");
const authenticateToken = require("../middlewares/authenticateToken");
const Unit = require("../models/Unit");


// 🔒 All routes require login
router.use(authenticateToken);

// ✅ Get all units with _id and name
router.get("/", async (req, res) => {
  try {
    const units = await Unit.find({ user: req.user.userId });
    res.json(units); // [{ _id, name }]
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});



// ✅ Add new unit (by creating a dummy flashcard with no content)
router.post("/", async (req, res) => {
  if (req.user.role !== "teacher") {
    return res.status(403).json({ error: "Only teachers can create units" });
  }

  const { name } = req.body;
  if (!name) return res.status(400).json({ error: "Unit name is required" });

  try {
    // Just create a flashcard with dummy data if unit doesn't exist
    const exists = await Flashcard.exists({ unit: name, user: req.user.userId });

    if (exists) {
      return res.status(409).json({ error: "Unit already exists" });
    }

    const dummy = new Flashcard({
      unit: name,
      topic: "Intro",
      question: "Dummy",
      answer: "Dummy",
      user: req.user.userId,
    });

    await dummy.save();
    res.status(201).json({ message: "Unit created" });
  } catch (err) {
    res.status(500).json({ error: "Error creating unit" });
  }
});

// ✅ Delete all flashcards in a unit (delete the unit)
router.delete("/:unitName", async (req, res) => {
  if (req.user.role !== "teacher") {
    return res.status(403).json({ error: "Only teachers can delete units" });
  }

  try {
    const result = await Flashcard.deleteMany({
      unit: req.params.unitName,
      user: req.user.userId,
    });

    if (result.deletedCount === 0) {
      return res.status(404).json({ message: "No flashcards found in this unit" });
    }

    res.status(200).json({ message: `Deleted ${result.deletedCount} flashcards in unit "${req.params.unitName}"` });
  } catch (err) {
    res.status(500).json({ error: "Error deleting unit" });
  }
});

module.exports = router;
