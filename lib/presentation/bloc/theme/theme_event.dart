part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeChanged extends ThemeEvent {
  final ThemeData themeData;

  const ThemeChanged({required this.themeData});

  @override
  List<Object> get props => [themeData];
}