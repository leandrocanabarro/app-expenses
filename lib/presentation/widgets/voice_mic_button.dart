import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/voice_provider.dart';

class VoiceMicButton extends ConsumerWidget {
  const VoiceMicButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceStateProvider);

    // Show feedback
    ref.listen(voiceStateProvider, (previous, next) {
      if (next.feedback != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.feedback!),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Clear feedback after showing
        Future.delayed(const Duration(seconds: 3), () {
          ref.read(voiceStateProvider.notifier).clearFeedback();
        });
      }
      
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Clear error after showing
        Future.delayed(const Duration(seconds: 3), () {
          ref.read(voiceStateProvider.notifier).clearFeedback();
        });
      }
    });

    return FloatingActionButton(
      onPressed: _getOnPressed(voiceState.status, ref),
      heroTag: 'voice_mic',
      backgroundColor: _getBackgroundColor(voiceState.status),
      child: _getIcon(voiceState.status),
    );
  }

  VoidCallback? _getOnPressed(VoiceStatus status, WidgetRef ref) {
    switch (status) {
      case VoiceStatus.idle:
        return () => ref.read(voiceStateProvider.notifier).startListening();
      case VoiceStatus.listening:
        return () => ref.read(voiceStateProvider.notifier).stopListening();
      case VoiceStatus.initializing:
      case VoiceStatus.processing:
        return null;
      case VoiceStatus.error:
        return () => ref.read(voiceStateProvider.notifier).initialize();
    }
  }

  Color _getBackgroundColor(VoiceStatus status) {
    switch (status) {
      case VoiceStatus.idle:
        return Colors.blue;
      case VoiceStatus.listening:
        return Colors.red;
      case VoiceStatus.processing:
        return Colors.orange;
      case VoiceStatus.initializing:
        return Colors.grey;
      case VoiceStatus.error:
        return Colors.red.shade300;
    }
  }

  Widget _getIcon(VoiceStatus status) {
    switch (status) {
      case VoiceStatus.idle:
        return const Icon(Icons.mic, color: Colors.white);
      case VoiceStatus.listening:
        return const Icon(Icons.mic, color: Colors.white);
      case VoiceStatus.processing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        );
      case VoiceStatus.initializing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        );
      case VoiceStatus.error:
        return const Icon(Icons.error, color: Colors.white);
    }
  }
}