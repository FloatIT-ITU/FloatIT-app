import 'package:firebase_auth/firebase_auth.dart';
import 'package:floatit/src/core/data/repositories/auth_repository.dart';
import 'package:floatit/src/core/data/repositories/event_repository.dart';
import 'package:floatit/src/core/data/repositories/notification_repository.dart';
import 'package:floatit/src/core/data/repositories/user_repository.dart';
import 'package:floatit/src/core/data/repositories/impl/firebase_auth_repository.dart';
import 'package:floatit/src/core/data/repositories/impl/firebase_event_repository.dart';
import 'package:floatit/src/core/data/repositories/impl/firebase_notification_repository.dart';
import 'package:floatit/src/core/data/repositories/impl/firebase_user_repository.dart';
import 'package:floatit/src/core/domain/usecases/auth_usecases.dart';
import 'package:floatit/src/core/domain/usecases/event_usecases.dart';
import 'package:floatit/src/core/domain/usecases/notification_usecases.dart';
import 'package:floatit/src/core/domain/usecases/user_usecases.dart';

/// Dependency injection container for managing app dependencies
class DependencyInjection {
  // Private constructor for singleton
  DependencyInjection._();

  // Singleton instance
  static final DependencyInjection instance = DependencyInjection._();

  // Firebase instances
  late final FirebaseAuth _firebaseAuth;

  // Repositories
  late final AuthRepository _authRepository;
  late final UserRepository _userRepository;
  late final EventRepository _eventRepository;
  late final NotificationRepository _notificationRepository;

  // Use cases
  late final SignInUseCase _signInUseCase;
  late final SignUpUseCase _signUpUseCase;
  late final SignOutUseCase _signOutUseCase;
  late final SendPasswordResetUseCase _sendPasswordResetUseCase;
  late final IsEmailVerifiedUseCase _isEmailVerifiedUseCase;
  late final SendEmailVerificationUseCase _sendEmailVerificationUseCase;

  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final GetUserByIdUseCase _getUserByIdUseCase;
  late final GetPublicUserByIdUseCase _getPublicUserByIdUseCase;
  late final UpdateUserProfileUseCase _updateUserProfileUseCase;
  late final GetAdminUsersUseCase _getAdminUsersUseCase;
  late final UserDocumentExistsUseCase _userDocumentExistsUseCase;
  late final CreateUserDocumentUseCase _createUserDocumentUseCase;

  late final GetEventsUseCase _getEventsUseCase;
  late final GetEventByIdUseCase _getEventByIdUseCase;
  late final CreateEventUseCase _createEventUseCase;
  late final UpdateEventUseCase _updateEventUseCase;
  late final DeleteEventUseCase _deleteEventUseCase;
  late final JoinEventUseCase _joinEventUseCase;
  late final LeaveEventUseCase _leaveEventUseCase;
  late final GetUserEventsUseCase _getUserEventsUseCase;

  late final GetGlobalBannerUseCase _getGlobalBannerUseCase;
  late final GetEventBannerUseCase _getEventBannerUseCase;
  late final SetGlobalBannerUseCase _setGlobalBannerUseCase;
  late final SetEventBannerUseCase _setEventBannerUseCase;
  late final DeleteGlobalBannerUseCase _deleteGlobalBannerUseCase;
  late final DeleteEventBannerUseCase _deleteEventBannerUseCase;

  /// Initialize all dependencies
  Future<void> initialize() async {
    _firebaseAuth = FirebaseAuth.instance;

    // Initialize repositories
    _authRepository = FirebaseAuthRepository(_firebaseAuth);
    _userRepository = FirebaseUserRepository(_firebaseAuth);
    _eventRepository = const FirebaseEventRepository();
    _notificationRepository = const FirebaseNotificationRepository();

    // Initialize use cases
    _signInUseCase = SignInUseCase(_authRepository);
    _signUpUseCase = SignUpUseCase(_authRepository);
    _signOutUseCase = SignOutUseCase(_authRepository);
    _sendPasswordResetUseCase = SendPasswordResetUseCase(_authRepository);
    _isEmailVerifiedUseCase = IsEmailVerifiedUseCase(_authRepository);
    _sendEmailVerificationUseCase = SendEmailVerificationUseCase(_authRepository);

    _getCurrentUserUseCase = GetCurrentUserUseCase(_userRepository);
    _getUserByIdUseCase = GetUserByIdUseCase(_userRepository);
    _getPublicUserByIdUseCase = GetPublicUserByIdUseCase(_userRepository);
    _updateUserProfileUseCase = UpdateUserProfileUseCase(_userRepository);
    _getAdminUsersUseCase = GetAdminUsersUseCase(_userRepository);
    _userDocumentExistsUseCase = UserDocumentExistsUseCase(_userRepository);
    _createUserDocumentUseCase = CreateUserDocumentUseCase(_userRepository);

    _getEventsUseCase = GetEventsUseCase(_eventRepository);
    _getEventByIdUseCase = GetEventByIdUseCase(_eventRepository);
    _createEventUseCase = CreateEventUseCase(_eventRepository);
    _updateEventUseCase = UpdateEventUseCase(_eventRepository);
    _deleteEventUseCase = DeleteEventUseCase(_eventRepository);
    _joinEventUseCase = JoinEventUseCase(_eventRepository);
    _leaveEventUseCase = LeaveEventUseCase(_eventRepository);
    _getUserEventsUseCase = GetUserEventsUseCase(_eventRepository);

    _getGlobalBannerUseCase = GetGlobalBannerUseCase(_notificationRepository);
    _getEventBannerUseCase = GetEventBannerUseCase(_notificationRepository);
    _setGlobalBannerUseCase = SetGlobalBannerUseCase(_notificationRepository);
    _setEventBannerUseCase = SetEventBannerUseCase(_notificationRepository);
    _deleteGlobalBannerUseCase = DeleteGlobalBannerUseCase(_notificationRepository);
    _deleteEventBannerUseCase = DeleteEventBannerUseCase(_notificationRepository);
  }

  // Getters for repositories
  AuthRepository get authRepository => _authRepository;
  UserRepository get userRepository => _userRepository;
  EventRepository get eventRepository => _eventRepository;
  NotificationRepository get notificationRepository => _notificationRepository;

  // Getters for use cases
  SignInUseCase get signInUseCase => _signInUseCase;
  SignUpUseCase get signUpUseCase => _signUpUseCase;
  SignOutUseCase get signOutUseCase => _signOutUseCase;
  SendPasswordResetUseCase get sendPasswordResetUseCase => _sendPasswordResetUseCase;
  IsEmailVerifiedUseCase get isEmailVerifiedUseCase => _isEmailVerifiedUseCase;
  SendEmailVerificationUseCase get sendEmailVerificationUseCase => _sendEmailVerificationUseCase;

  GetCurrentUserUseCase get getCurrentUserUseCase => _getCurrentUserUseCase;
  GetUserByIdUseCase get getUserByIdUseCase => _getUserByIdUseCase;
  GetPublicUserByIdUseCase get getPublicUserByIdUseCase => _getPublicUserByIdUseCase;
  UpdateUserProfileUseCase get updateUserProfileUseCase => _updateUserProfileUseCase;
  GetAdminUsersUseCase get getAdminUsersUseCase => _getAdminUsersUseCase;
  UserDocumentExistsUseCase get userDocumentExistsUseCase => _userDocumentExistsUseCase;
  CreateUserDocumentUseCase get createUserDocumentUseCase => _createUserDocumentUseCase;

  GetEventsUseCase get getEventsUseCase => _getEventsUseCase;
  GetEventByIdUseCase get getEventByIdUseCase => _getEventByIdUseCase;
  CreateEventUseCase get createEventUseCase => _createEventUseCase;
  UpdateEventUseCase get updateEventUseCase => _updateEventUseCase;
  DeleteEventUseCase get deleteEventUseCase => _deleteEventUseCase;
  JoinEventUseCase get joinEventUseCase => _joinEventUseCase;
  LeaveEventUseCase get leaveEventUseCase => _leaveEventUseCase;
  GetUserEventsUseCase get getUserEventsUseCase => _getUserEventsUseCase;

  GetGlobalBannerUseCase get getGlobalBannerUseCase => _getGlobalBannerUseCase;
  GetEventBannerUseCase get getEventBannerUseCase => _getEventBannerUseCase;
  SetGlobalBannerUseCase get setGlobalBannerUseCase => _setGlobalBannerUseCase;
  SetEventBannerUseCase get setEventBannerUseCase => _setEventBannerUseCase;
  DeleteGlobalBannerUseCase get deleteGlobalBannerUseCase => _deleteGlobalBannerUseCase;
  DeleteEventBannerUseCase get deleteEventBannerUseCase => _deleteEventBannerUseCase;
}