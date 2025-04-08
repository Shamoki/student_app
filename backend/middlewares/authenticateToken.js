const jwt = require('jsonwebtoken');
const User = require('../models/User'); // ⬅️ Needed to fetch full user details

async function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ msg: 'Access denied. No token provided.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.SECRET_KEY || 'defaultsecret');

    // ✅ Fetch the full user to access the role
    const user = await User.findById(decoded.userId);
    if (!user) {
      return res.status(404).json({ msg: 'User not found.' });
    }

    // ✅ Attach userId and role for downstream use
    req.user = {
      userId: user._id,
      role: user.role,
    };

    next();
  } catch (err) {
    return res.status(403).json({ msg: 'Invalid or expired token' });
  }
}

module.exports = authenticateToken;
