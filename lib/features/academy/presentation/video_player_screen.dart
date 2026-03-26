import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Video Area
          Container(
            width: double.infinity,
            height: 230,
            color: AppTheme.surfaceColor,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  LucideIcons.playCircle,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Slider(
                    value: 0.3,
                    onChanged: (v) {},
                    activeColor: AppTheme.primaryColor,
                    inactiveColor: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Introduction to Compounding',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Section 1: The Magic of Time',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'In this lesson, you will learn how small amounts of money invested consistently can grow into a large corpus over time using the power of compounding.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Up Next',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildNextLesson(
                          '2. Simple vs Compound Interest',
                          '12:45',
                        ),
                        _buildNextLesson('3. The Rule of 72', '08:20'),
                        _buildNextLesson('4. Starting Early vs Late', '15:10'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextLesson(String title, String duration) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          LucideIcons.play,
          size: 16,
          color: AppTheme.textSecondary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        duration,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
    );
  }
}
