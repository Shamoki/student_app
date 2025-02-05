const nodemailer = require('nodemailer');
const EmailOTP = require('../models/emailOTP');

// Configure Nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

/**
 * Generate a 6-digit OTP
 * @returns {string} - Random 6-digit OTP
 */
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

/**
 * Save or Update OTP in the database
 * @param {string} email - User's email
 * @param {string} otp - OTP code
 */
const saveOrUpdateOTP = async (email, otp) => {
  try {
    const existingOTP = await EmailOTP.findOne({ email });
    if (existingOTP) {
      console.log(`Updating existing OTP for email: ${email}`);
      existingOTP.otp = otp;
      existingOTP.createdAt = Date.now();
      await existingOTP.save();
    } else {
      console.log(`Saving new OTP for email: ${email}`);
      await EmailOTP.create({ email, otp });
    }
  } catch (error) {
    console.error(`Error saving OTP for email ${email}:`, error.message);
    throw new Error('Could not save OTP. Please try again.');
  }
};

/**
 * Send OTP via email
 * @param {string} email - Recipient's email address
 * @param {string} otp - OTP to send
 */
const sendOTPEmail = async (email, otp) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Your OTP Code',
    text: `Your OTP code is: ${otp}. This code is valid for 5 minutes.`,
  };

  try {
    console.log(`Sending OTP email to: ${email}`);
    await transporter.sendMail(mailOptions);
    console.log(`OTP email sent to: ${email}`);
  } catch (error) {
    console.error(`Error sending OTP email to ${email}:`, error.message);
    throw new Error('Could not send OTP email. Please try again.');
  }
};

/**
 * Generate and send OTP
 * @param {string} email - Recipient's email address
 */
const generateAndSendOTP = async (email) => {
  try {
    const otp = generateOTP();
    console.log(`Generated OTP for email ${email}: ${otp}`);
    await saveOrUpdateOTP(email, otp);
    await sendOTPEmail(email, otp);
  } catch (error) {
    console.error(`Error generating or sending OTP for ${email}:`, error.message);
    throw error;
  }
};

/**
 * Verify the OTP
 * @param {string} email - User's email
 * @param {string} otp - OTP entered by the user
 * @returns {boolean} - Whether OTP is valid
 */
const verifyOTP = async (email, otp) => {
  try {
    console.log(`Verifying OTP for email: ${email}`);
    const record = await EmailOTP.findOne({ email, otp });

    if (!record) {
      console.error(`OTP verification failed for email ${email}: OTP not found or expired.`);
      throw new Error('Invalid or expired OTP');
    }

    // OTP is valid, remove it from the database
    await EmailOTP.deleteOne({ email });
    console.log(`OTP verified and deleted for email: ${email}`);
    return true;
  } catch (error) {
    console.error(`Error verifying OTP for email ${email}:`, error.message);
    throw new Error('Invalid or expired OTP');
  }
};

module.exports = {
  generateAndSendOTP,
  verifyOTP,
};
