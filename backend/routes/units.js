const express = require("express");
const router = express.Router();
const Unit = require("../models/Unit");
const authenticateToken = require("../middlewares/authenticateToken"); // ✅ Middleware

// ✅ Get all units for the logged-in user
router.get("/", authenticateToken, async (req, res) => {
  try {
    const units = await Unit.find({ user: req.user.userId }).sort({ name: 1 });
    res.json(units.map(u => u.name));
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

// ✅ Add a new unit for the logged-in user
router.post("/", authenticateToken, async (req, res) => {
  const { name } = req.body;
  if (!name) return res.status(400).json({ error: "Unit name is required" });

  try {
    const unit = new Unit({
      name,
      user: req.user.userId, // ✅ Associate with user from JWT
    });

    await unit.save();
    res.status(201).json(unit);
  } catch (err) {
    if (err.code === 11000) {
      return res.status(409).json({ error: "Unit already exists" });
    }
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
