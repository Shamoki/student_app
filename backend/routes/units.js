const express = require("express");
const router = express.Router();
const crypto = require("crypto");
const authenticateToken = require("../middlewares/authenticateToken");
const Unit = require("../models/Unit");
const Flashcard = require("../models/Flashcard");

router.use(authenticateToken);

// 🔐 Generate a unique alphanumeric unit code
function generateUnitCode() {
  return crypto.randomBytes(4).toString("hex").toUpperCase(); // e.g., "9F3A2D1B"
}

// ✅ GET /api/units - Get units for the current user
router.get("/", async (req, res) => {
  const userId = req.user.userId;

  try {
    let units;
    if (req.user.role === "teacher") {
      units = await Unit.find({ teacher: userId });
    } else {
      units = await Unit.find({ students: userId });
    }
    res.json(units);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch units" });
  }
});

// ✅ POST /api/units - Teacher creates a new unit with a unique code
router.post("/", async (req, res) => {
  if (req.user.role !== "teacher") {
    return res.status(403).json({ error: "Only teachers can create units" });
  }

  const { name } = req.body;
  if (!name) return res.status(400).json({ error: "Unit name is required" });

  try {
    const existing = await Unit.findOne({ name, teacher: req.user.userId });
    if (existing) {
      return res.status(409).json({ error: "Unit already exists" });
    }

    const unit = new Unit({
      name,
      teacher: req.user.userId,
      students: [],
      code: generateUnitCode(), // generate a unique code
    });

    await unit.save();
    res.status(201).json(unit); // return unit and its code
  } catch (err) {
    res.status(500).json({ error: "Error creating unit" });
  }
});

// ✅ POST /api/units/enroll-by-code - Student joins a unit using code
router.post("/enroll-by-code", async (req, res) => {
  const { code } = req.body;
  const studentId = req.user.userId;

  try {
    const unit = await Unit.findOne({ code });
    if (!unit) return res.status(404).json({ error: "Invalid unit code" });

    if (!unit.students.includes(studentId)) {
      unit.students.push(studentId);
      await unit.save();
    }

    res.json(unit);
  } catch (err) {
    res.status(500).json({ error: "Failed to enroll in unit" });
  }
});

// ✅ POST /api/units/enroll - Teacher/Admin enrolls student manually
router.post("/enroll", async (req, res) => {
  const { unitId, studentId } = req.body;

  try {
    const unit = await Unit.findById(unitId);
    if (!unit) return res.status(404).json({ error: "Unit not found" });

    if (!unit.students.includes(studentId)) {
      unit.students.push(studentId);
      await unit.save();
    }

    res.json({ message: "Student enrolled successfully" });
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

// ✅ DELETE /api/units/:id - Delete unit & its flashcards
router.delete("/:unitId", async (req, res) => {
  const { unitId } = req.params;

  if (req.user.role !== "teacher") {
    return res.status(403).json({ error: "Only teachers can delete units" });
  }

  try {
    const unit = await Unit.findOne({ _id: unitId, teacher: req.user.userId });
    if (!unit) return res.status(404).json({ error: "Unit not found or unauthorized" });

    // Delete flashcards under this unit
    await Flashcard.deleteMany({ unit: unit._id });

    // Then delete the unit
    await Unit.deleteOne({ _id: unit._id });

    res.json({ message: "Unit and its flashcards deleted" });
  } catch (err) {
    res.status(500).json({ error: "Error deleting unit" });
  }
});

module.exports = router;
