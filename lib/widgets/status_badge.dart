import 'package:flutter/material.dart';
import '../core/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: FittedBox(child: Padding(padding: const EdgeInsets.all(6.0), child: Text(prettyStatus(status).split(' ').map((s)=>s[0]).take(2).join(), style: const TextStyle(fontWeight: FontWeight.bold)))),
    );
  }
}
