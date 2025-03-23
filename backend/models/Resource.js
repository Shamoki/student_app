const mongoose = require("mongoose");

const ResourceSchema = new mongoose.Schema({
  subject: {
    type: String,
    required: true,
    trim: true,
  },
  title: {
    type: String,
    required: true,
  },
  url: {
    type: String, // Could be a document link or video
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  type: {
    type: String, // e.g., "PDF", "Video", "Article"
    required: true,
  },
});

module.exports = mongoose.model("Resource", ResourceSchema);
