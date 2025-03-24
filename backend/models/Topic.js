const mongoose = require('mongoose');

const topicSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
  },
  unit: {
    type: String,
    required: true,
    trim: true,
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true, // ✅ This ensures the topic is tied to a specific user
  },
}, {
  timestamps: true, // Optional: adds createdAt and updatedAt
});

module.exports = mongoose.model('Topic', topicSchema);
