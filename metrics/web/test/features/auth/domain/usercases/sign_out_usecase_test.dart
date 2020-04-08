import 'package:metrics/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../../test_utils/matcher_util.dart';
import 'test_utils/error_user_repository_mock.dart';
import 'test_utils/user_repository_mock.dart';

void main() {
  group("SignOutUseCase", () {
    test("can't be created with null repository", () {
      expect(
        () => SignOutUseCase(null),
        MatcherUtil.throwsAssertionError,
      );
    });

    test("delegates call to the UserRepository.signOut", () async {
      final repository = UserRepositoryMock();
      final signOutUseCase = SignOutUseCase(repository);

      await signOutUseCase();

      verify(repository.signOut()).called(equals(1));
    });

    test(
      "throws if UserRepository throws during sign out",
      () {
        final repository = ErrorUserRepositoryMock();
        final signOutUseCase = SignOutUseCase(repository);

        expect(
          () => signOutUseCase(),
          MatcherUtil.throwsAuthenticationException,
        );
      },
    );
  });
}
