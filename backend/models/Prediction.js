const mongoose = require("mongoose");

const PredictionSchema = new mongoose.Schema({
  imageId: { type: mongoose.Schema.Types.ObjectId, ref: "Image", required: true }, // Reference to Image
  userId: { type: String, required: true }, // Reference to the user
  predictionData: { type: mongoose.Schema.Types.Mixed, required: true }, // Store prediction metadata (JSON or object)
  createdAt: { type: Date, default: Date.now }, // Timestamp
});

module.exports = mongoose.model("Prediction", PredictionSchema);
