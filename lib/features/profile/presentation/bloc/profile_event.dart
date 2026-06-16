import 'dart:typed_data';
import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class LoadProfile extends ProfileEvent {
  final String uid;

  const LoadProfile(this.uid);

  @override
  List<Object?> get props => [uid];
}

final class UpdateAvatar extends ProfileEvent {
  final Uint8List imageBytes;

  const UpdateAvatar(this.imageBytes);

  @override
  List<Object?> get props => [imageBytes];
}

final class LoadOrderHistory extends ProfileEvent {
  final String uid;

  const LoadOrderHistory(this.uid);

  @override
  List<Object?> get props => [uid];
}
