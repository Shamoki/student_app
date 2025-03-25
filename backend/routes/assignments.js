const express = require('express');
const router = express.Router();
const Assignment = require('../models/Assignment');
const { google } = require('googleapis');
const authenticateToken = require('../middlewares/authenticateToken'); // ✅ Import auth middleware

// Google OAuth2 credentials (replace with your real values)
const CLIENT_ID = 'YOUR_GOOGLE_CLIENT_ID';
const CLIENT_SECRET = 'YOUR_GOOGLE_CLIENT_SECRET';
const REDIRECT_URI = 'com.your.app://callback';

const oauth2Client = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI);

//
// 🔒 All routes below this line require authentication
//
router.use(authenticateToken); // ✅ Protect all following routes

// 📌 Add a new assignment (user-specific)
router.post('/', async (req, res) => {
  try {
    const { title, description, dueDate } = req.body;

    const newAssignment = new Assignment({
      title,
      description,
      dueDate,
      user: req.user.userId, // ✅ Save user ID from token
    });

    await newAssignment.save();
    res.status(201).json(newAssignment);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create assignment' });
  }
});

// 📌 Get all assignments for the logged-in user
router.get('/', async (req, res) => {
  try {
    const assignments = await Assignment.find({ user: req.user.userId }); // ✅ Filter by user
    res.status(200).json(assignments);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch assignments' });
  }
});

// 📌 Mark assignment as completed (user-specific)
router.put('/:id', async (req, res) => {
  try {
    const assignment = await Assignment.findOne({ _id: req.params.id, user: req.user.userId });

    if (!assignment) return res.status(404).json({ error: 'Assignment not found or not yours' });

    assignment.completed = !assignment.completed;
    await assignment.save();
    res.status(200).json(assignment);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update assignment' });
  }
});

// 📌 Delete an assignment (user-specific)
router.delete('/:id', async (req, res) => {
  try {
    const assignment = await Assignment.findOneAndDelete({ _id: req.params.id, user: req.user.userId });

    if (!assignment) return res.status(404).json({ error: 'Assignment not found or not yours' });

    res.status(200).json({ message: 'Assignment deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete assignment' });
  }
});

//
// ✅ Public routes (no token required)
//

router.post('/google-classroom/token', async (req, res) => {
  try {
    const { code } = req.body;
    const { tokens } = await oauth2Client.getToken(code);
    oauth2Client.setCredentials(tokens);
    res.status(200).json({ accessToken: tokens.access_token });
  } catch (err) {
    res.status(500).json({ error: 'Failed to exchange code for token' });
  }
});

router.post('/google-classroom/assignments', async (req, res) => {
  try {
    const { code } = req.body;
    const { tokens } = await oauth2Client.getToken(code);
    oauth2Client.setCredentials(tokens);

    const classroom = google.classroom({ version: 'v1', auth: oauth2Client });

    const coursesResponse = await classroom.courses.list({ pageSize: 10 });
    const courses = coursesResponse.data.courses || [];
    const assignments = [];

    for (const course of courses) {
      const courseworkResponse = await classroom.courses.courseWork.list({ courseId: course.id });
      const coursework = courseworkResponse.data.courseWork || [];

      coursework.forEach((assignment) => {
        assignments.push({
          title: assignment.title,
          description: assignment.description || 'No description',
          dueDate: assignment.dueDate
            ? new Date(assignment.dueDate.year, assignment.dueDate.month - 1, assignment.dueDate.day).toISOString()
            : null,
        });
      });
    }

    res.status(200).json(assignments);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch assignments from Google Classroom' });
  }
});

module.exports = router;
