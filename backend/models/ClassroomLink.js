const mongoose = require('mongoose');

const ClassroomLinkSchema = new mongoose.Schema({
  className: {
    type: String,
    required: true,
  },
  classCode: {
    type: String,
    required: true,
  },
  meetingLink: {
    type: String,
    required: true,
    validate: {
      validator: v => /^https?:\/\/.+/.test(v),
      message: props => `${props.value} is not a valid URL!`,
    },
  },
  platform: {
    type: String,
    enum: ['Zoom', 'Google Classroom', 'Google Meet', 'Microsoft Teams', 'Other'],
    required: true,
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
}, { timestamps: true });

module.exports = mongoose.model('ClassroomLink', ClassroomLinkSchema);
