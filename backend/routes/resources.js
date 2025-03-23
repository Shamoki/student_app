const express = require("express");
const router = express.Router();
const Resource = require("../models/Resource");

// ✅ Get resources by subject
router.get("/:subject", async (req, res) => {
  try {
    const resources = await Resource.find({ subject: req.params.subject });
    res.json(resources);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

// ✅ Add a new resource
router.post("/", async (req, res) => {
  const { subject, title, url, description, type } = req.body;

  if (!subject || !title || !url || !description || !type) {
    return res.status(400).json({ error: "All fields are required" });
  }

  try {
    const newResource = new Resource({ subject, title, url, description, type });
    await newResource.save();
    res.status(201).json(newResource);
  } catch (err) {
    res.status(500).json({ error: "Error saving resource" });
  }
});

module.exports = router;
