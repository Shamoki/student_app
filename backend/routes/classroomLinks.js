const express = require('express');
const jwt = require('jsonwebtoken');
const ClassroomLink = require('../models/ClassroomLink');

const router = express.Router();
const SECRET = process.env.SECRET_KEY || 'defaultsecret';

// ⛳ Helper: decode token from header
function extractUserIdFromToken(req) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) throw new Error('Token missing');

  const decoded = jwt.verify(token, SECRET);
  return decoded.userId;
}

// ✅ POST /api/classroom-links (create a new link)
router.post('/', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req);
    const { className, classCode, meetingLink, platform } = req.body;

    if (!className || !classCode || !meetingLink || !platform) {
      return res.status(400).json({ msg: 'All fields are required.' });
    }

    const newLink = new ClassroomLink({
      className,
      classCode,
      meetingLink,
      platform,
      createdBy: userId,
    });

    const saved = await newLink.save();
    res.status(201).json(saved);
  } catch (err) {
    console.error('Error saving classroom link:', err.message);
    res.status(403).json({ msg: 'Invalid or missing token' });
  }
});

// ✅ GET /api/classroom-links (fetch links for logged-in user)
router.get('/', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req);

    const links = await ClassroomLink.find({ createdBy: userId }).sort({ createdAt: -1 });
    res.json(links);
  } catch (err) {
    console.error('Error fetching classroom links:', err.message);
    res.status(403).json({ msg: 'Invalid or missing token' });
  }
});

// ✅ DELETE /api/classroom-links/:id (delete if owned by user)
router.delete('/:id', async (req, res) => {
  try {
    const userId = extractUserIdFromToken(req);

    const link = await ClassroomLink.findById(req.params.id);
    if (!link) return res.status(404).json({ msg: 'Link not found' });

    if (link.createdBy.toString() !== userId) {
      return res.status(403).json({ msg: 'Not authorized to delete this link' });
    }

    await ClassroomLink.findByIdAndDelete(req.params.id);
    res.json({ msg: 'Classroom link deleted successfully' });
  } catch (err) {
    console.error('Error deleting link:', err.message);
    res.status(403).json({ msg: 'Invalid or missing token' });
  }
});

module.exports = router;
