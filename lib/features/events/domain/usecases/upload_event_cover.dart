import 'dart:io';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/event_repository.dart';

class UploadEventCover extends UseCase<String, File> {
  final EventRepository repo;
  const UploadEventCover(this.repo);

  @override
  Future<Either<Failure, String>> call(File file) => repo.uploadCover(file);
}
