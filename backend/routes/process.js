const axios = require("axios");
const Prediction = require("../models/Prediction"); // Prediction model
let io;

async function processImage(image) {
  try {
    // Ensure Socket.IO is initialized
    if (!io) {
      io = require("../socket").getIO();
    }

    const flaskApiUrl = "https://d7af-34-124-197-24.ngrok-free.app/predict"; // Flask API endpoint

    // Send image to Flask API
    const flaskResponse = await axios.post(flaskApiUrl, image.data, {
      headers: {
        "Content-Type": "application/octet-stream",
      },
    });

    const { predictions, image: processedImage } = flaskResponse.data;

    // Save predictions to MongoDB
    const newPrediction = new Prediction({
      imageId: image._id, // Link to uploaded image
      userId: image.userId, // Link to user
      predictionData: predictions, // Save parsed predictions
    });

    const savedPrediction = await newPrediction.save();
    console.log(`Prediction saved for Image ID: ${image._id}`);

    // Notify the frontend via WebSocket
    io.to(image.userId).emit("predictionComplete", {
      imageId: image._id,
      predictionId: savedPrediction._id,
      predictions,
      processedImage, // Send processed image back to the frontend
    });
  } catch (error) {
    console.error("Error processing image via Flask API:", error.message);

    // Notify the frontend of the error
    io.to(image.userId).emit("processingError", {
      msg: "Error processing image",
      error: error.message,
    });
  }
}

module.exports = { processImage };
