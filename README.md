# Student App
##Student Companion App
A cross-platform Flutter app designed to help students manage their academic life efficiently. It includes tools to organize flashcards, manage assignments, keep track of online class details, and get personalized academic article recommendations — all based on user-selected interests.

##🚀 Features
#Flashcards
Teachers create flashcards by unit and topic.

Students access flashcards based on the units they are enrolled in.

Flashcards support flip-style interaction, and teachers can edit/delete flashcards.

Topics are nested under units, making it easy to navigate.

#Assignments
Teachers add assignments linked to a specific unit.

Students can view assignments by unit, along with due dates and descriptions.

Supports dynamic refresh for new assignments and updates.

#Online Class Tracking
Add and organize classroom links (e.g., Zoom, Google Classroom) by unit.

Includes fields for class name, day of the week, and platform.

Helps students stay on top of their online or hybrid classes.

#Personalized Article Feed
Students pick their academic interests during onboarding (e.g., AI, Psychology, Law).

A content-based recommendation system suggests research papers or articles related to selected interests.

Articles are pulled from curated sources like arXiv and displayed in a scrollable feed.

#Tech Stack
Frontend: Flutter (Dart)

Backend: Node.js (Express), Python (Flask for ML model)

Database: MongoDB Atlas

ML: TF-IDF + Cosine Similarity for content-based recommendation

Authentication: JWT tokens, Role-based access (Admin, Teacher, Student)


