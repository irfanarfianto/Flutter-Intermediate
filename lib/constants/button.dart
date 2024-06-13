import 'package:flutter/material.dart';

final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
  foregroundColor: Colors.white,
  backgroundColor: Colors.blue,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);

final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
  foregroundColor: Colors.black,
  backgroundColor: Colors.grey[300],
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    side: const BorderSide(color: Colors.grey),
  ),
);

final ButtonStyle iconButtonStyle = ElevatedButton.styleFrom(
  foregroundColor: Colors.white,
  backgroundColor: Colors.orange,
  shape: const CircleBorder(),
  padding: const EdgeInsets.all(12),
);
