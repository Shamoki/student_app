const express = require("express");
const multer = require("multer");
const cors = require("cors");
const Image = require("../models/Image");
const { processImage } = require("./process"); // Import the processing logic

const router = express.Router();

router.use(cors());

const storage = multer.memoryStorage();
const upload = multer({ storage });

router.post("/", upload.single("file"), async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({ msg: "User ID is required" });
    }

    if (!req.file) {
      return res.status(400).json({ msg: "No file uploaded" });
    }

    // Save the uploaded image to MongoDB
    const newImage = new Image({
      filename: req.file.originalname,
      contentType: req.file.mimetype,
      data: req.file.buffer,
      userId: userId,
    });

    const savedImage = await newImage.save();

    console.log(`Image uploaded: ${savedImage.filename} by User ID: ${userId}`);

    // Respond to the frontend immediately after saving the image
    res.status(201).json({ msg: "Image uploaded successfully", imageId: savedImage._id });

    // Trigger image processing in a separate file
    processImage(savedImage); // Call the processing function
  } catch (err) {
    console.error("Upload error:", err.message);
    res.status(500).send("Server error");
  }
});

module.exports = router;
