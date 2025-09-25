import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/worker.dart';
import '../../providers/auth_provider.dart';

class WorkerDropdown extends StatelessWidget {
  const WorkerDropdown({super.key, required this.onSelected});

  final ValueChanged<Worker> onSelected;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return StreamBuilder<List<Worker>>(
      stream: auth.listenWorkers(),
      builder: (context, snapshot) {
        final workers = snapshot.data ?? [];
        if (workers.isEmpty) {
          return const SizedBox.shrink();
        }
        return DropdownButtonFormField<Worker>(
          items: workers
              .map(
                (worker) => DropdownMenuItem(
                  value: worker,
                  child: Text(worker.fullName),
                ),
              )
              .toList(),
          decoration: const InputDecoration(
            labelText: 'اختر عامل',
          ),
          onChanged: (worker) {
            if (worker != null) onSelected(worker);
          },
        );
      },
    );
  }
}
