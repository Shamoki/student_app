const express = require('express');
const router = express.Router();
const Assignment = require('../models/Assignment');
const axios = require('axios'); // For making HTTP requests to Google APIs
const { google } = require('googleapis'); // Google APIs client library

// Google OAuth2 credentials (replace with your own)
const CLIENT_ID = 'YOUR_GOOGLE_CLIENT_ID';
const CLIENT_SECRET = 'YOUR_GOOGLE_CLIENT_SECRET';
const REDIRECT_URI = 'com.your.app://callback'; // Must match your Flutter app's redirect URI

// Initialize Google OAuth2 client
const oauth2Client = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI);

// 📌 Add a new assignment
router.post('/', async (req, res) => {
  try {
    const { title, dueDate } = req.body;
    const newAssignment = new Assignment({ title, dueDate });
    await newAssignment.save();
    res.status(201).json(newAssignment);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create assignment' });
  }
});

// 📌 Get all assignments
router.get('/', async (req, res) => {
  try {
    const assignments = await Assignment.find();
    res.status(200).json(assignments);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch assignments' });
  }
});

// 📌 Mark an assignment as completed
router.put('/:id', async (req, res) => {
  try {
    const assignment = await Assignment.findById(req.params.id);
    if (!assignment) return res.status(404).json({ error: 'Assignment not found' });

    assignment.completed = !assignment.completed; // Toggle completion status
    await assignment.save();
    res.status(200).json(assignment);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update assignment' });
  }
});

// 📌 Delete an assignment
router.delete('/:id', async (req, res) => {
  try {
    await Assignment.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'Assignment deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete assignment' });
  }
});

// 🔑 Google Classroom: Exchange authorization code for access token
router.post('/google-classroom/token', async (req, res) => {
  try {
    const { code } = req.body;

    // Exchange code for access token
    const { tokens } = await oauth2Client.getToken(code);
    oauth2Client.setCredentials(tokens);

    res.status(200).json({ accessToken: tokens.access_token });
  } catch (err) {
    res.status(500).json({ error: 'Failed to exchange code for token' });
  }
});

// 📚 Google Classroom: Fetch assignments
router.post('/google-classroom/assignments', async (req, res) => {
  try {
    const { code } = req.body;

    // Exchange code for access token
    const { tokens } = await oauth2Client.getToken(code);
    oauth2Client.setCredentials(tokens);

    // Initialize Google Classroom API
    const classroom = google.classroom({ version: 'v1', auth: oauth2Client });

    // Fetch courses
    const coursesResponse = await classroom.courses.list({
      pageSize: 10,
    });

    const courses = coursesResponse.data.courses || [];
    const assignments = [];

    // Fetch assignments for each course
    for (const course of courses) {
      const courseworkResponse = await classroom.courses.courseWork.list({
        courseId: course.id,
      });

      const coursework = courseworkResponse.data.courseWork || [];
      coursework.forEach((assignment) => {
        assignments.push({
          title: assignment.title,
          description: assignment.description || 'No description',
          dueDate: assignment.dueDate ? new Date(assignment.dueDate.year, assignment.dueDate.month - 1, assignment.dueDate.day).toISOString() : null,
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