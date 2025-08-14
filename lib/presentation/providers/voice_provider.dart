import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/voice_intent_parser.dart';
import '../../data/services/voice_service.dart';
import '../../domain/entities/category.dart';
import 'category_providers.dart';
import 'expense_providers.dart';

// Voice service provider
final voiceServiceProvider = Provider<VoiceService>((ref) {
  return VoiceService();
});

// Voice state provider
final voiceStateProvider = StateNotifierProvider<VoiceStateController, VoiceState>((ref) {
  final voiceService = ref.watch(voiceServiceProvider);
  return VoiceStateController(voiceService, ref);
});

enum VoiceStatus { idle, initializing, listening, processing, error }

class VoiceState {
  final VoiceStatus status;
  final String? lastText;
  final String? error;
  final String? feedback;

  const VoiceState({
    this.status = VoiceStatus.idle,
    this.lastText,
    this.error,
    this.feedback,
  });

  VoiceState copyWith({
    VoiceStatus? status,
    String? lastText,
    String? error,
    String? feedback,
  }) {
    return VoiceState(
      status: status ?? this.status,
      lastText: lastText ?? this.lastText,
      error: error ?? this.error,
      feedback: feedback ?? this.feedback,
    );
  }
}

class VoiceStateController extends StateNotifier<VoiceState> {
  final VoiceService _voiceService;
  final Ref _ref;

  VoiceStateController(this._voiceService, this._ref) : super(const VoiceState());

  Future<void> initialize() async {
    state = state.copyWith(status: VoiceStatus.initializing);
    
    try {
      final initialized = await _voiceService.initialize();
      if (initialized) {
        state = state.copyWith(status: VoiceStatus.idle, error: null);
      } else {
        state = state.copyWith(
          status: VoiceStatus.error,
          error: 'Failed to initialize voice recognition',
        );
      }
    } catch (error) {
      state = state.copyWith(
        status: VoiceStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> startListening() async {
    if (!_voiceService.isAvailable) {
      await initialize();
      if (!_voiceService.isAvailable) return;
    }

    state = state.copyWith(status: VoiceStatus.listening, error: null);

    try {
      await _voiceService.startListening(
        onResult: _handleVoiceResult,
        listenFor: const Duration(seconds: 10),
      );
    } catch (error) {
      state = state.copyWith(
        status: VoiceStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> stopListening() async {
    if (_voiceService.isListening) {
      await _voiceService.stopListening();
    }
    state = state.copyWith(status: VoiceStatus.idle);
  }

  void _handleVoiceResult(String text) async {
    state = state.copyWith(
      status: VoiceStatus.processing,
      lastText: text,
    );

    try {
      final intent = VoiceIntentParser.parse(text);
      await _processIntent(intent);
    } catch (error) {
      state = state.copyWith(
        status: VoiceStatus.error,
        error: 'Failed to process voice command: $error',
      );
    }
  }

  Future<void> _processIntent(VoiceIntent intent) async {
    switch (intent) {
      case CreateCategory(:final name):
        await _createCategory(name);
        break;
      case AddExpense(:final value, :final description, :final categoryName):
        await _addExpense(value, description, categoryName);
        break;
      case Unknown():
        state = state.copyWith(
          status: VoiceStatus.idle,
          feedback: 'Comando não reconhecido. Tente novamente.',
        );
        break;
    }
  }

  Future<void> _createCategory(String name) async {
    try {
      final controller = _ref.read(addCategoryControllerProvider.notifier);
      await controller.addCategory(name);
      
      state = state.copyWith(
        status: VoiceStatus.idle,
        feedback: 'Categoria "$name" criada com sucesso!',
      );
    } catch (error) {
      state = state.copyWith(
        status: VoiceStatus.error,
        error: 'Erro ao criar categoria: $error',
      );
    }
  }

  Future<void> _addExpense(double value, String description, String? categoryName) async {
    try {
      int? categoryId;
      
      // Find category if specified
      if (categoryName != null) {
        final categories = await _ref.read(categoriesProvider.future);
        final category = categories.cast<Category?>().firstWhere(
          (cat) => cat?.name.toLowerCase() == categoryName.toLowerCase(),
          orElse: () => null,
        );
        categoryId = category?.id;
      }

      final controller = _ref.read(addExpenseControllerProvider.notifier);
      await controller.addExpense(
        value: value,
        description: description,
        categoryId: categoryId,
      );
      
      state = state.copyWith(
        status: VoiceStatus.idle,
        feedback: 'Gasto de R\$ ${value.toStringAsFixed(2)} adicionado com sucesso!',
      );
    } catch (error) {
      state = state.copyWith(
        status: VoiceStatus.error,
        error: 'Erro ao adicionar gasto: $error',
      );
    }
  }

  void clearFeedback() {
    state = state.copyWith(feedback: null, error: null);
  }
}