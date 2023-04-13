import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/services/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    // send email verification
    on<AuthEventSendVerificationEmail>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      if (email.isEmpty || password.isEmpty) {
        emit(AuthStateRegistering(EmailOrPasswordEmptyAuthException()));
        return;
      }
      Future.delayed(const Duration(seconds: 3));
      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification());
      } on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    });
    on<AuthEventShouldRegister>((event, emit) async {
      try {
        emit(const AuthStateRegistering(null));
      } on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    });
    // initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });
    // login
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
      ));
      final email = event.email;
      final password = event.password;
      if (email.isEmpty || password.isEmpty) {
        emit(AuthStateLoggedOut(
          exception: EmailOrPasswordEmptyAuthException(),
          isLoading: false,
        ));
        return;
      }
      await Future.delayed(const Duration(seconds: 3));
      try {
        final user = await provider.logIn(email: email, password: password);
        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));
          emit(const AuthStateNeedsVerification());
        } else {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));
          emit(AuthStateLoggedIn(user));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });
    // logout
    on<AuthEventLogOut>((event, emit) async {
      try {
        emit(const AuthStateLoading());
        await provider.logout();
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });
  }
}
