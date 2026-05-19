#!/bin/bash
# Run this to add more test stories to Firebase
# Make sure you're logged in to Firebase first: firebase login

cd "C:\Users\DELL\Downloads\IPS MEDIDENT\APP\medident"

echo "Adding test stories to Firebase..."
flutter run lib/scripts/seed_more_stories.dart

echo "Done! Check Firebase console for new stories in 'stories' collection."
