import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';

/// Real-time messaging is a later phase of this app (student <-> startup
/// chat, backed by Firestore `conversations`/`messages` collections). This
/// tab stays in the nav to match the product's information architecture,
/// but shows an honest empty state instead of fabricated conversations.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const EmptyState(
        icon: Icons.forum_outlined,
        title: 'Messaging is coming soon',
        message:
            'Once a startup accepts your application, you\'ll be able to chat with them directly here.',
      ),
    );
  }
}
