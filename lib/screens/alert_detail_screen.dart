import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../theme/app_theme.dart';

class AlertDetailScreen extends StatelessWidget {
  final Alert alert;

  const AlertDetailScreen({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final isWaterQuality = alert.type == AlertType.waterQuality;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Alert Details'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.gray300,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Alert Type Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isWaterQuality ? AppTheme.blue500 : AppTheme.orange500,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isWaterQuality ? Icons.water_drop : Icons.pest_control,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alert.typeDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Alert Message Box - Full content from backend
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.gray300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.gray600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Alert Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.gray900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Full alert message with markdown-style formatting
                  _buildFormattedMessage(alert.message),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Timestamp
            Text(
              _formatDateTime(alert.timestamp),
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build formatted message widget that handles newlines and bullet points
  Widget _buildFormattedMessage(String message) {
    final lines = message.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();
        
        // Check if it's a bullet point
        if (trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*')) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRichText(trimmed.substring(1).trim()),
                ),
              ],
            ),
          );
        }
        
        // Regular paragraph
        if (trimmed.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildRichText(trimmed),
          );
        }
        
        return const SizedBox(height: 8);
      }).toList(),
    );
  }

  /// Build rich text with bold formatting (**text**)
  Widget _buildRichText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before the match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.gray700,
            height: 1.5,
          ),
        ));
      }

      // Add bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.gray900,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ));

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.gray700,
          height: 1.5,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  String _formatDateTime(DateTime time) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[time.month - 1]} ${time.day}, ${time.year} at '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
