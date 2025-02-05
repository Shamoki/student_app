const mongoose = require("mongoose");

const ImageSchema = new mongoose.Schema({
  filename: { type: String, required: true },
  contentType: { type: String, required: true },
  data: { type: Buffer, required: true }, // Binary file data
  userId: { type: String, required: true }, // User ID reference
  uploadedAt: { type: Date, default: Date.now }, // Upload timestamp
});

module.exports = mongoose.model("Image", ImageSchema);
