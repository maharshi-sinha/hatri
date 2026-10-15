/// Barrel + helpers around `fpdart`'s Either.
///
/// Call sites import this one file instead of pulling in `package:fpdart`
/// everywhere, so if we ever swap the Either implementation it is a single
/// edit here.
library;

export 'package:fpdart/fpdart.dart' show Either, Left, Right, Option, Some, None;
