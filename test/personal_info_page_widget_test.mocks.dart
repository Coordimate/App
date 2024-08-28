// Mocks generated by Mockito 5.4.4 from annotations
// in coordimate/test/personal_info_page_widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;
import 'dart:typed_data' as _i9;

import 'package:coordimate/controllers/auth_controller.dart' as _i5;
import 'package:coordimate/controllers/user_controller.dart' as _i10;
import 'package:coordimate/models/user.dart' as _i4;
import 'package:google_sign_in/google_sign_in.dart' as _i3;
import 'package:googleapis/calendar/v3.dart' as _i7;
import 'package:googleapis_auth/googleapis_auth.dart' as _i6;
import 'package:http/http.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeClient_0 extends _i1.SmartFake implements _i2.Client {
  _FakeClient_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeGoogleSignIn_1 extends _i1.SmartFake implements _i3.GoogleSignIn {
  _FakeGoogleSignIn_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUser_2 extends _i1.SmartFake implements _i4.User {
  _FakeUser_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [AuthorizationController].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthorizationController extends _i1.Mock
    implements _i5.AuthorizationController {
  MockAuthorizationController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Client get plainClient => (super.noSuchMethod(
        Invocation.getter(#plainClient),
        returnValue: _FakeClient_0(
          this,
          Invocation.getter(#plainClient),
        ),
      ) as _i2.Client);

  @override
  _i3.GoogleSignIn get googleSignIn => (super.noSuchMethod(
        Invocation.getter(#googleSignIn),
        returnValue: _FakeGoogleSignIn_1(
          this,
          Invocation.getter(#googleSignIn),
        ),
      ) as _i3.GoogleSignIn);

  @override
  set googleAuthClient(_i6.AuthClient? _googleAuthClient) => super.noSuchMethod(
        Invocation.setter(
          #googleAuthClient,
          _googleAuthClient,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set calApi(_i7.CalendarApi? _calApi) => super.noSuchMethod(
        Invocation.setter(
          #calApi,
          _calApi,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set userId(String? _userId) => super.noSuchMethod(
        Invocation.setter(
          #userId,
          _userId,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<String?> getAccountId() => (super.noSuchMethod(
        Invocation.method(
          #getAccountId,
          [],
        ),
        returnValue: _i8.Future<String?>.value(),
      ) as _i8.Future<String?>);

  @override
  _i8.Future<bool> trySilentGoogleSignIn() => (super.noSuchMethod(
        Invocation.method(
          #trySilentGoogleSignIn,
          [],
        ),
        returnValue: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  _i8.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<bool> signIn(
    dynamic email,
    dynamic signInMethod, {
    dynamic password,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #signIn,
          [
            email,
            signInMethod,
          ],
          {#password: password},
        ),
        returnValue: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  _i8.Future<bool> register(
    dynamic email,
    dynamic username,
    dynamic signInMethod, {
    dynamic password,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #register,
          [
            email,
            username,
            signInMethod,
          ],
          {#password: password},
        ),
        returnValue: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  _i8.Future<bool> checkStoredToken() => (super.noSuchMethod(
        Invocation.method(
          #checkStoredToken,
          [],
        ),
        returnValue: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  _i8.Future<_i9.Uint8List> cropToSquare(_i9.Uint8List? imageBytes) =>
      (super.noSuchMethod(
        Invocation.method(
          #cropToSquare,
          [imageBytes],
        ),
        returnValue: _i8.Future<_i9.Uint8List>.value(_i9.Uint8List(0)),
      ) as _i8.Future<_i9.Uint8List>);

  @override
  _i8.Future<bool> checkAuthType(dynamic authType) => (super.noSuchMethod(
        Invocation.method(
          #checkAuthType,
          [authType],
        ),
        returnValue: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);
}

/// A class which mocks [UserController].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserController extends _i1.Mock implements _i10.UserController {
  MockUserController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Future<void> setFcmToken(String? fcmToken) => (super.noSuchMethod(
        Invocation.method(
          #setFcmToken,
          [fcmToken],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<_i4.User> getInfo() => (super.noSuchMethod(
        Invocation.method(
          #getInfo,
          [],
        ),
        returnValue: _i8.Future<_i4.User>.value(_FakeUser_2(
          this,
          Invocation.method(
            #getInfo,
            [],
          ),
        )),
      ) as _i8.Future<_i4.User>);

  @override
  _i8.Future<void> changeUsername(
    dynamic username,
    dynamic id,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #changeUsername,
          [
            username,
            id,
          ],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> deleteUser(dynamic id) => (super.noSuchMethod(
        Invocation.method(
          #deleteUser,
          [id],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<bool> sendChangePswdRequest(
    dynamic newPswd,
    dynamic oldPswd,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #sendChangePswdRequest,
          [
            newPswd,
            oldPswd,
          ],
        ),
        returnValue: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  _i8.Future<void> updateLocation() => (super.noSuchMethod(
        Invocation.method(
          #updateLocation,
          [],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> updateRandomCoffee(
    dynamic id,
    dynamic data,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateRandomCoffee,
          [
            id,
            data,
          ],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
}
