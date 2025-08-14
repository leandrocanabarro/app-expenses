import '../../core/app_constants.dart';
import '../../core/currency_format.dart';

sealed class VoiceIntent {
  const VoiceIntent();
}

class CreateCategory extends VoiceIntent {
  final String name;
  const CreateCategory(this.name);
}

class AddExpense extends VoiceIntent {
  final double value;
  final String description;
  final String? categoryName;
  final DateTime? date;

  const AddExpense({
    required this.value,
    required this.description,
    this.categoryName,
    this.date,
  });
}

class Unknown extends VoiceIntent {
  const Unknown();
}

class VoiceIntentParser {
  static VoiceIntent parse(String text) {
    final normalized = _normalizeText(text);
    
    // Try to parse create category intent
    final categoryIntent = _parseCreateCategory(normalized);
    if (categoryIntent != null) return categoryIntent;
    
    // Try to parse add expense intent
    final expenseIntent = _parseAddExpense(normalized);
    if (expenseIntent != null) return expenseIntent;
    
    return const Unknown();
  }

  static String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static CreateCategory? _parseCreateCategory(String text) {
    final patterns = [
      RegExp(AppConstants.createCategoryPattern, caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final name = match.group(1)?.trim();
        if (name != null && name.isNotEmpty) {
          return CreateCategory(name);
        }
      }
    }

    return null;
  }

  static AddExpense? _parseAddExpense(String text) {
    // Remove "reais" from text
    String cleanText = text.replaceAll(RegExp(r'\s+reais?\b'), '');
    
    // Try different expense patterns
    final patterns = [
      // "adicionar gasto {valor} {descrição}"
      RegExp(r'(?:adicionar|lançar|inserir)\s+gasto\s+(.+)', caseSensitive: false),
      // "gastei {valor} em {descrição}"
      RegExp(r'gastei\s+(.+)\s+em\s+(.+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(cleanText);
      if (match != null) {
        if (pattern.pattern.contains('gastei')) {
          // Handle "gastei X em Y" format
          final valueText = match.group(1)?.trim();
          final description = match.group(2)?.trim();
          
          if (valueText != null && description != null) {
            final value = _extractValue(valueText);
            if (value != null) {
              final (cleanDesc, category) = _extractCategory(description);
              return AddExpense(
                value: value,
                description: cleanDesc,
                categoryName: category,
              );
            }
          }
        } else {
          // Handle "adicionar gasto X Y" format
          final content = match.group(1)?.trim();
          if (content != null) {
            final value = _extractValue(content);
            if (value != null) {
              // Extract description (everything after the value)
              final valuePattern = RegExp(AppConstants.valuePattern);
              final valueMatch = valuePattern.firstMatch(content);
              if (valueMatch != null) {
                final description = content
                    .substring(valueMatch.end)
                    .trim();
                
                if (description.isNotEmpty) {
                  final (cleanDesc, category) = _extractCategory(description);
                  return AddExpense(
                    value: value,
                    description: cleanDesc,
                    categoryName: category,
                  );
                }
              }
            }
          }
        }
      }
    }

    return null;
  }

  static double? _extractValue(String text) {
    final valuePattern = RegExp(AppConstants.valuePattern);
    final match = valuePattern.firstMatch(text);
    
    if (match != null) {
      final valueText = match.group(1);
      if (valueText != null) {
        return CurrencyFormat.parseFromText(valueText);
      }
    }
    
    return null;
  }

  static (String description, String? category) _extractCategory(String text) {
    final categoryPattern = RegExp(AppConstants.categoryInlinePattern, caseSensitive: false);
    final match = categoryPattern.firstMatch(text);
    
    if (match != null) {
      final category = match.group(1)?.trim();
      final description = text.replaceAll(categoryPattern, '').trim();
      return (description, category);
    }
    
    return (text, null);
  }
}