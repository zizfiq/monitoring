import 'package:flutter/material.dart';

// Function to show a customized SnackBar
showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          border: Border.all(color: Colors.blue, width: 2), // Blue border
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Shadow for neo-brutalism
              offset: Offset(4, 4), // Shadow offset
              blurRadius: 4, // Shadow blur
              spreadRadius: 0, // No spread
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black, // Text color
            fontSize: 16, // Font size
            fontWeight: FontWeight.normal, // Normal weight for text
          ),
        ),
      ),
      behavior: SnackBarBehavior.floating, // Allows for a floating SnackBar
      backgroundColor:
          Colors.transparent, // Transparent background for the snackbar
      elevation: 0, // No shadow for the snackbar
    ),
  );
}
