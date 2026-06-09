import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/profile/domain/repositories/profile_repository.dart';

class UpdateAvatarUseCase {
  final ProfileRepository repository;

  UpdateAvatarUseCase(this.repository);

  Future<Either<Failure, String>> call(String uid, String filePath) {
    return repository.updateAvatar(uid, filePath);
  }
}
