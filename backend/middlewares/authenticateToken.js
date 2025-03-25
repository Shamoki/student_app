const jwt = require('jsonwebtoken');

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  
  // Token format: "Bearer <token>"
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ msg: 'Access denied. No token provided.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.SECRET_KEY || 'defaultsecret');
    req.user = decoded; // Makes user info (like userId) available in req.user
    next();
  } catch (err) {
    return res.status(403).json({ msg: 'Invalid or expired token' });
  }
}

module.exports = authenticateToken;
