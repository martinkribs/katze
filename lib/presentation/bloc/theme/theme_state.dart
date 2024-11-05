part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final ThemeData themeData;
  final bool isDarkMode;

  const ThemeState({
    required this.themeData,
    required this.isDarkMode,
  });

  @override
  List<Object> get props => [themeData, isDarkMode];

  ThemeState copyWith({
    ThemeData? themeData,
    bool? isDarkMode,
  }) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
