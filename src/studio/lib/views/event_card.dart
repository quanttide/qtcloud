import 'package:flutter/material.dart';
import '../models/event.dart';
import '../constants.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDeprecated = event.status == 'deprecated';
    final isChangePending = event.status == 'change_pending';

    return Card(
      child: Container(
        decoration: isChangePending
            ? BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.orange.shade400, width: 4),
                ),
              )
            : null,
        child: ListTile(
          onTap: onTap,
          enabled: !isDeprecated,
          title: Text(
            event.type,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: isDeprecated ? TextDecoration.lineThrough : null,
              color: isDeprecated ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                domainLabel(event.source),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              Text(
                event.description,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Badge(
                backgroundColor: eventDirectionColor(event.direction),
                textStyle: const TextStyle(color: Colors.white, fontSize: 11),
                label: Text(eventDirectionLabel(event.direction)),
              ),
              const SizedBox(height: 4),
              Text(
                event.version,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              Text(
                '${event.subscriberCount} 订阅',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
