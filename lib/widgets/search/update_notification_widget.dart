import 'package:flutter/material.dart';

class UpdateNotificationWidget extends StatelessWidget {
  final VoidCallback onShowWhatsNew;

  const UpdateNotificationWidget({
    super.key,
    required this.onShowWhatsNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "psychphinder just got updated!",
              style: TextStyle(
                fontFamily: 'PsychFont',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onShowWhatsNew,
              child: Text(
                "See what's new",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontFamily: 'PsychFont',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
