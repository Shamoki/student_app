const mongoose = require('mongoose');

const ProfilePhotoSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  photo: {
    type: Buffer, // Store the image data
    required: true,
  },
  contentType: {
    type: String, // MIME type of the photo (e.g., 'image/jpeg')
    required: true,
  },
}, { timestamps: true });

module.exports = mongoose.model('ProfilePhoto', ProfilePhotoSchema);
