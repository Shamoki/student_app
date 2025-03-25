const mongoose = require("mongoose");

// Define schema
const FlashcardSchema = new mongoose.Schema(
  {
    unit: {
      type: String,
      required: true,
      trim: true,
    },
    topic: {
      type: String,
      required: true,
      trim: true,
    },
    question: {
      type: String,
      required: true,
      trim: true,
    },
    answer: {
      type: String,
      required: true,
      trim: true,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true, // ✅ Ensure each flashcard belongs to a user
    },
  },
  {
    timestamps: true, // Adds createdAt and updatedAt fields automatically
  }
);

// Export model
module.exports = mongoose.model("Flashcard", FlashcardSchema);
