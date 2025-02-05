const express = require('express');
const multer = require('multer');
const jwt = require('jsonwebtoken');
const ProfilePhoto = require('../models/ProfilePhoto');

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage }); // Multer for handling file uploads

// Middleware to verify JWT token
const verifyToken = (req, res, next) => {
  const token = req.header('Authorization')?.split(' ')[1]; // Extract Bearer token

  if (!token) {
    return res.status(403).json({ msg: 'Access denied, no token provided.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.SECRET_KEY || 'defaultsecret');
    req.user = decoded; // Attach decoded payload (e.g., userId) to the request object
    next(); // Proceed to the next middleware or route handler
  } catch (err) {
    res.status(401).json({ msg: 'Invalid or expired token.' });
  }
};

// POST /upload - Upload profile photo (Protected)
router.post('/upload', verifyToken, upload.single('file'), async (req, res) => {
  try {
    const userId = req.user.userId; // Extract user ID from the token
    const file = req.file;

    if (!file) {
      return res.status(400).json({ msg: 'No file uploaded.' });
    }

    // Check if a profile photo already exists
    let profilePhoto = await ProfilePhoto.findOne({ userId });
    if (profilePhoto) {
      // Update the existing photo
      profilePhoto.photo = file.buffer;
      profilePhoto.contentType = file.mimetype;
    } else {
      // Save a new profile photo
      profilePhoto = new ProfilePhoto({
        userId,
        photo: file.buffer,
        contentType: file.mimetype,
      });
    }

    await profilePhoto.save();
    res.status(201).json({ msg: 'Profile photo uploaded successfully.' });
  } catch (err) {
    console.error('Upload error:', err.message);
    res.status(500).json({ msg: 'Error uploading profile photo.' });
  }
});

// GET /photo - Retrieve profile photo (Protected)
router.get('/photo', verifyToken, async (req, res) => {
  try {
    const userId = req.user.userId; // Extract user ID from the token
    const profilePhoto = await ProfilePhoto.findOne({ userId });

    if (!profilePhoto) {
      return res.status(404).json({ msg: 'Profile photo not found.' });
    }

    res.set('Content-Type', profilePhoto.contentType);
    res.send(profilePhoto.photo); // Send the photo as a binary response
  } catch (err) {
    console.error('Retrieve error:', err.message);
    res.status(500).json({ msg: 'Error retrieving profile photo.' });
  }
})

router.delete('/photo', verifyToken, async (req, res) => {
  try {
    const userId = req.user.userId; // Extract user ID from token
    const profilePhoto = await ProfilePhoto.findOne({ userId });

    if (!profilePhoto) {
      return res.status(404).json({ msg: 'Profile photo not found.' });
    }

    await ProfilePhoto.deleteOne({ userId });
    res.status(200).json({ msg: 'Profile photo removed successfully.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Error removing profile photo.' });
  }
});


module.exports = router;
