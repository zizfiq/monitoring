import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final String status;

  const CustomContainer({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    IconData icon;
    String text; // Define a local variable for the text message

    // Determine the border color, icon, and text based on the status
    switch (status) {
      case 'optimal':
        borderColor = Colors.green;
        icon = Icons.check_circle; // Icon for optimal status
        text =
            'Semua parameter berada dalam rentang ideal'; // Message for optimal status
        break;
      case 'attention':
        borderColor = Colors.yellow;
        icon = Icons.warning; // Icon for attention status
        text =
            'Salah satu atau beberapa parameter mendekati batas yang kurang ideal'; // Message for attention status
        break;
      case 'danger':
        borderColor = Colors.red;
        icon = Icons.error; // Icon for danger status
        text =
            'Parameter sangat ekstrem, mengharuskan tindakan segera'; // Message for danger status
        break;
      default:
        borderColor = Colors.grey; // Default color if status is unknown
        icon = Icons.info; // Default icon
        text = 'Status tidak diketahui'; // Default message
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(4, 4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor), // Display the icon
          const SizedBox(width: 10), // Space between icon and text
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
