require('dotenv').config(); // Load environment variables
const express = require('express');
const http = require('http'); // Required for Socket.IO integration
const mongoose = require('mongoose');
const cors = require('cors');
const { init } = require('./socket'); // WebSocket initialization
const authRoutes = require('./routes/auth'); // Authentication routes
const uploadRoutes = require('./routes/upload'); // Upload route
const profileRoutes = require('./routes/profile'); // Profile photo routes
const mediumRoutes = require('./routes/mediumRoutes'); // ✅ Medium Articles Fetch Route
const assignmentRoutes = require('./routes/assignments'); // Import assignments routes
const flashcardsRoutes= require('./routes/flashcards');
const unitRoutes = require("./routes/units");
const topicsRoutes = require('./routes/topics');



const app = express();
const server = http.createServer(app); // Create HTTP server for Express and WebSocket

// ✅ Enable CORS with better security
app.use(cors({
  origin: '*', // Allow all origins (adjust for production)
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// ✅ Middleware to parse JSON requests
app.use(express.json());

// ✅ Initialize WebSocket server
const io = init(server); // Initialize and get the Socket.IO instance

// ✅ MongoDB Connection
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('✅ MongoDB connected successfully'))
  .catch((error) => {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1); // Exit the app if MongoDB connection fails
  });

// ✅ Log MongoDB connection events
mongoose.connection.on('connected', () => console.log('✅ Mongoose connected to MongoDB'));
mongoose.connection.on('error', (error) => console.error('❌ Mongoose connection error:', error));

// ✅ Define API routes
app.use('/api/auth', authRoutes); // Authentication 
app.use('/api/upload', uploadRoutes); // Upload route
app.use('/api/profile', profileRoutes); // Profile pic route
app.use('/api/medium', mediumRoutes); // ✅ Medium Articles Fetch Route
app.use('/api/assignments', assignmentRoutes); // ✅ Mount the assignments API
app.use('/api/flashcards', flashcardsRoutes);
app.use("/api/units", unitRoutes);
app.use('/api/topics', topicsRoutes);



// ✅ Root API Route (Useful for testing server status)
app.get('/', (req, res) => {
  res.status(200).json({ message: '🚀 Server is running successfully!' });
});

// ✅ Catch-all route for undefined endpoints
app.use((req, res) => {
  res.status(404).json({ error: '❌ Route not found' });
});

// ✅ Error Handling Middleware
app.use((err, req, res, next) => {
  console.error('❌ Server Error:', err);
  res.status(500).json({ error: '❌ Internal Server Error' });
});

// ✅ Start the server
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));

// ✅ Export the MongoDB connection for reuse
module.exports = mongoose.connection;
