const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { generateAndSendOTP, verifyOTP } = require('../services/emailOTPService');
const cors = require('cors');
const router = express.Router();

router.use(cors());

// ✅ Allow only Strathmore University email addresses
function isSchoolEmail(email) {
  const regex = /^[a-zA-Z0-9._%+-]+@strathmore\.edu$/;
  return regex.test(email);
}

// ✅ Temporary storage for unverified users
let pendingUsers = {};

// ✅ SIGNUP - Generate OTP & Temporarily Save User
router.post('/signup', async (req, res) => {
  const { username, email, password, role } = req.body;

  try {
    if (!username || !email || !password) {
      return res.status(400).json({ msg: 'All fields are required.' });
    }

    if (!isSchoolEmail(email)) {
      return res.status(400).json({ msg: 'Only @strathmore.edu emails are allowed.' });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ msg: 'User already registered. Please log in.' });
    }

    // Generate & Send OTP
    console.log(`Generating OTP for email: ${email}`);
    await generateAndSendOTP(email);

    // Save user details temporarily in memory
    pendingUsers[email] = { username, email, password, role: role || 'student' };
    console.log(`User details temporarily saved: ${JSON.stringify(pendingUsers[email])}`);

    res.status(201).json({ msg: 'OTP sent to your Strathmore email.' });
  } catch (err) {
    console.error('Signup error:', err.message);
    res.status(500).json({ msg: 'Error sending OTP. Please try again later.' });
  }
});

// ✅ VERIFY OTP & FINALIZE USER REGISTRATION
router.post('/verify-otp', async (req, res) => {
  const { email, otp } = req.body;

  try {
    if (!email || !otp) {
      return res.status(400).json({ msg: 'Email and OTP are required.' });
    }

    // Verify OTP
    console.log(`Verifying OTP for email: ${email}`);
    await verifyOTP(email, otp);

    const userDetails = pendingUsers[email];
    if (!userDetails) {
      return res.status(400).json({ msg: 'User details not found. Please sign up again.' });
    }

    // ✅ Save user to database with role
    const user = new User({
      ...userDetails,
      isEmailVerified: true,
      interestsSet: false,
    });

    await user.save();
    console.log(`User successfully registered: ${email}`);

    // Remove user from temporary storage
    delete pendingUsers[email];

    res.status(201).json({ msg: 'Account created successfully. Please log in.' });
  } catch (err) {
    console.error('OTP verification error:', err.message);
    res.status(400).json({ msg: 'Invalid or expired OTP. Please try again.' });
  }
});

// ✅ LOGIN & CHECK IF USER NEEDS TO SET INTERESTS
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(400).json({ msg: 'Invalid credentials. Please try again.' });
    }

    if (!user.isEmailVerified) {
      return res.status(403).json({ msg: 'Email not verified. Please verify before logging in.' });
    }

    const isMatch = await user.verifyPassword(password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Invalid credentials. Please try again.' });
    }

    const interestsNeeded = !user.interestsSet;

    const payload = { userId: user.id };
    const token = jwt.sign(payload, process.env.SECRET_KEY || 'defaultsecret', { expiresIn: '1h' });

    console.log(`User logged in: ${email}`);
    res.status(200).json({
      token,
      userId: user.id,
      user: {
        username: user.username,
        email: user.email,
        role: user.role, // ✅ include role here
        interestsSet: user.interestsSet,
        interests: user.interests || { categories: [], subcategories: [] },
      },
      interestsNeeded,
    });
  } catch (err) {
    console.error('Login error:', err.message);
    res.status(500).json({ msg: 'Server error. Please try again later.' });
  }
});

// ✅ SET USER INTERESTS
router.put('/set-interests', async (req, res) => {
  const { userId, categories, subcategories } = req.body;

  try {
    let user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    user.interests = { categories, subcategories };
    user.interestsSet = true;
    await user.save();

    res.json({ msg: 'Interests updated successfully', interests: user.interests });
  } catch (err) {
    console.error('Interest update error:', err.message);
    res.status(500).json({ msg: 'Server error' });
  }
});

// ✅ GET USER INTERESTS
router.get('/get-interests/:userId', async (req, res) => {
  try {
    const user = await User.findById(req.params.userId).select('interests interestsSet');

    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    res.json({ interests: user.interests });
  } catch (err) {
    console.error('Fetch interests error:', err.message);
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;
