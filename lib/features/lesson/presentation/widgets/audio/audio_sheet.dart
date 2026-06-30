import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../data/models/lesson_model.dart';
import '../shared/sheet_button.dart';

class LessonAudioSheet extends StatelessWidget {
  final LessonAudio audio;
  final bool audioLoading;
  final bool audioReady;
  final String? audioError;
  final AudioPlayer? audioPlayer;
  final Future<void> Function() onRetryAudio;

  const LessonAudioSheet({
    super.key,
    required this.audio,
    required this.audioLoading,
    required this.audioReady,
    required this.audioError,
    required this.audioPlayer,
    required this.onRetryAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.badge),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Audio',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          if (audioLoading)
            const Text(
              'Loading audio...',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
            )
          else if (audioError != null)
            Text(
              audioError!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
            )
          else
            const Text(
              'Play the audio for this lesson',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
            ),
          const SizedBox(height: 24),
          if (audioReady && audioPlayer != null)
            StreamBuilder<PlayerState>(
              stream: audioPlayer?.playerStateStream ?? const Stream.empty(),
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return SheetButton(
                  label: playing ? 'Pause Audio' : 'Play Audio',
                  icon:
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  isPrimary: true,
                  onTap: () async {
                    if (audioPlayer == null) return;
                    if (playing) {
                      await audioPlayer!.pause();
                    } else {
                      await audioPlayer!.play();
                    }
                  },
                );
              },
            )
          else
            SheetButton(
              label: 'Try Again',
              icon: Icons.refresh_rounded,
              isPrimary: false,
              onTap: onRetryAudio,
            ),
        ],
      ),
    );
  }
}
