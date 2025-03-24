const mongoose = require("mongoose");

const UnitSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  user: {  // ✅ Associate unit with a specific user
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
});

UnitSchema.index({ name: 1, user: 1 }, { unique: true }); // ✅ Prevent duplicate units per user

module.exports = mongoose.model("Unit", UnitSchema);
