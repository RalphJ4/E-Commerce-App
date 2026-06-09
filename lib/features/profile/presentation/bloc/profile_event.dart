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
  final String filePath;

  const UpdateAvatar(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

final class LoadOrderHistory extends ProfileEvent {
  final String uid;

  const LoadOrderHistory(this.uid);

  @override
  List<Object?> get props => [uid];
}
