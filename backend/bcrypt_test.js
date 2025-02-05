// passwords do not match:  issue with password was hashin during signup.
// passwords match: bcrypt is working correctly, issue in  app logic.
//const bcrypt = require('bcryptjs');
//const enteredPassword = 'Cosmic2814';  // Replace with your password
//const hashedPassword = '$2a$10$FGdWxKF7utRI3fH7oE1A.u/lxyWmJHaMmD0lzVuxIo0eegmHj0FRe';  // Use the hash from MongoDB

//bcrypt.compare(enteredPassword, hashedPassword, (err, isMatch) => {
  //if (err) {
    //console.error('Error comparing passwords:', err);
  //} else if (isMatch) {
    //console.log('Passwords match!');
  //} else {
  //  console.log('Passwords do not match.');
  //}
//});

// console output npm warn deprecated inflight@1.0.6: This module is not supported,
// and leaks memory. Do not use it. Check out lru-cache if you want a good and tested 
// way to coalesce async requests by a key value, which is much more comprehensive and powerful.
