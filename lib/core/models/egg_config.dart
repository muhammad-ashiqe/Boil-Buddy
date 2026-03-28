import 'package:flutter/foundation.dart';

enum EggSize { small, medium, large }

enum EggTemp { fridge, room }

enum EggStyle { soft, medium, hard }

@immutable
class EggConfig {
  final EggSize size;
  final EggTemp temp;
  final EggStyle style;

  const EggConfig({
    required this.size,
    required this.temp,
    required this.style,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EggConfig &&
          runtimeType == other.runtimeType &&
          size == other.size &&
          temp == other.temp &&
          style == other.style;

  @override
  int get hashCode => Object.hash(size, temp, style);

  EggConfig copyWith({EggSize? size, EggTemp? temp, EggStyle? style}) {
    return EggConfig(
      size: size ?? this.size,
      temp: temp ?? this.temp,
      style: style ?? this.style,
    );
  }

  @override
  String toString() =>
      'EggConfig(size: $size, temp: $temp, style: $style)';
}
