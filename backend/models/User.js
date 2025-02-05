const mongoose = require('mongoose');
const argon2 = require('argon2');

const UserSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true, trim: true },
  email: { type: String, required: true, unique: true, trim: true },
  password: { type: String, required: true },
  isEmailVerified: { type: Boolean, default: false }, 
  interestsSet: { type: Boolean, default: false }, // ✅ Track if interests are selected
  interests: {
    categories: { type: [String], default: [] }, // ✅ Stores main interest categories (e.g., "Technology")
    subcategories: { type: [String], default: [] }, // ✅ Stores specific sub-interests (e.g., "AI & Machine Learning")
  },
  createdAt: { type: Date, default: Date.now },
});

// 🔒 Hash password before saving
UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  try {
    this.password = await argon2.hash(this.password);
    next();
  } catch (err) {
    next(err);
  }
});

// 🔑 Verify password during login
UserSchema.methods.verifyPassword = async function (password) {
  return argon2.verify(this.password, password);
};

module.exports = mongoose.model('User', UserSchema);
