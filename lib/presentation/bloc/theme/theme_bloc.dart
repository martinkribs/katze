import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:katze/presentation/theme/app_colors.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(
    themeData: AppColors.darkTheme,
    isDarkMode: true,
  )) {
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) {
    final isDarkMode = !state.isDarkMode;
    emit(ThemeState(
      themeData: isDarkMode ? AppColors.darkTheme : AppColors.lightTheme,
      isDarkMode: isDarkMode,
    ));
  }
}
