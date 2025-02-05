const { Server } = require("socket.io");

let io; // Variable to hold the Socket.IO instance

module.exports = {
  // Initialize the WebSocket server
  init: (server) => {
    io = new Server(server, {
      cors: {
        origin: "*", // Allow all origins (adjust in production)
        methods: ["GET", "POST"],
      },
    });

    // Handle WebSocket connections
    io.on("connection", (socket) => {
      console.log("WebSocket client connected");

      // Handle joining a specific room based on user ID
      socket.on("join", (userId) => {
        console.log(`User joined room: ${userId}`);
        socket.join(userId); // Join the user's unique room
      });

      // Handle disconnection
      socket.on("disconnect", () => {
        console.log("WebSocket client disconnected");
      });
    });

    return io; // Return the WebSocket instance
  },

  // Retrieve the WebSocket instance
  getIO: () => {
    if (!io) {
      throw new Error("Socket.IO not initialized");
    }
    return io;
  },
};
