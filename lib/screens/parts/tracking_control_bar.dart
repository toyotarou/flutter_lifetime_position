import 'package:flutter/material.dart';

class TrackingControlBar extends StatelessWidget {
  const TrackingControlBar({
    super.key,
    required this.statusText,
    required this.isRunning,
    required this.onStart,
    required this.onStop,
    required this.onReload,
  });

  final String statusText;
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: <Widget>[
          Text(
            statusText,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: isRunning ? null : onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent.withOpacity(0.8),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('開始', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: isRunning ? onStop : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.stop),
                label: const Text('停止', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: onReload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.withOpacity(0.7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('再読込', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
