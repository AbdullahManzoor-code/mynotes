# MyNotes Cleanup Patterns Guide

## Overview
This document standardizes resource cleanup patterns across BLoCs and Screens to prevent memory leaks and ensure proper app lifecycle management.

---

## 1. BLoC Resource Cleanup Pattern

### Pattern for BLoCs with Resources (Streams, Controllers, Services)

**✅ CORRECT - BLoC with close() override:**

```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  final ServiceA _serviceA;
  final ServiceB _serviceB;
  StreamSubscription? _streamSubscription;

  MyBloc({
    required ServiceA serviceA,
    required ServiceB serviceB,
  })
    : _serviceA = serviceA,
      _serviceB = serviceB,
      super(MyInitial()) {
    on<MyEvent>(_onMyEvent);
  }

  Future<void> _onMyEvent(MyEvent event, Emitter<MyState> emit) async {
    // Start listening to a stream
    _streamSubscription = _serviceA.stream.listen((data) {
      // Handle data
    });
  }

  @override
  Future<void> close() async {
    // CLEANUP 1: Cancel stream subscriptions
    await _streamSubscription?.cancel();
    
    // CLEANUP 2: Stop services or cleanup resources
    _serviceB.cleanup(); // if service has cleanup method
    
    // CLEANUP 3: Call super.close() at the end
    return super.close();
  }
}
```

### Pattern for Singletons with Service Cleanup

**✅ CORRECT - Service with dispose() method:**

```dart
class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._();
  
  final SpeechToText _speechToText = SpeechToText();
  
  VoiceCommandService._();
  
  factory VoiceCommandService() => _instance;
  
  // Regular methods...
  
  /// Cleanup method to be called during app shutdown
  void dispose() {
    _speechToText.stop();
    _speechToText.cancel();
    // Clear any callbacks/listeners
  }
}
```

**Register in injection_container.dart:**
```dart
getIt.registerSingleton<VoiceCommandService>(VoiceCommandService());
```

**Call during app shutdown in main.dart:**
```dart
// In main() or WidgetsBindingObserver.didChangeAppLifecycleState()
if (state == AppLifecycleState.detached) {
  getIt<VoiceCommandService>().dispose();
}
```

---

## 2. StatefulWidget Resource Cleanup Pattern

### Pattern for Screens with Resources (Controllers, Focus Nodes, Listeners)

**✅ CORRECT - Screen with proper dispose():**

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // Controllers
  late TextEditingController _titleController;
  late AnimationController _animationController;
  
  // Focus nodes
  late FocusNode _focusNode;
  
  // Subscriptions
  StreamSubscription? _subscription;
  
  // Other resources
  late WakelockPlus _wakelock;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _titleController = TextEditingController();
    _focusNode = FocusNode();
    
    // Initialize animation controller with vsync
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Subscribe to streams
    _subscription = someStream.listen((event) {
      if (mounted) {
        setState(() {
          // Update state
        });
      }
    });
    
    // Enable device features (wakelock, etc)
    WakelockPlus.enable();
    
    // Load initial data
    _loadData();
  }

  Future<void> _loadData() async {
    // Load initial data
  }

  @override
  void dispose() {
    // CLEANUP 1: Cancel subscriptions
    _subscription?.cancel();
    
    // CLEANUP 2: Dispose focus nodes
    _focusNode.dispose();
    
    // CLEANUP 3: Dispose animation controllers
    _animationController.dispose();
    
    // CLEANUP 4: Dispose text editing controllers
    _titleController.dispose();
    
    // CLEANUP 5: Cleanup device features
    WakelockPlus.disable(); // Restore normal screen lock
    
    // CLEANUP 6: Close any other resources
    // (ServiceB cleanup, etc)
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No side effects in build()!
      body: Column(
        children: [
          TextField(controller: _titleController),
          // Rest of UI
        ],
      ),
    );
  }
}
```

---

## 3. StreamSubscription Cleanup Pattern

### Problem: Uncancelled Subscriptions

**❌ WRONG - Uncancelled subscription:**
```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() {
    on<LoadEvent>((event, emit) {
      // This subscription is never cancelled!
      _repository.stream.listen((data) {
        emit(MyState(data));
      });
    });
  }
}
```

**✅ CORRECT - Proper subscription handling:**
```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  StreamSubscription? _streamSubscription;
  
  MyBloc(this._repository) : super(MyInitial()) {
    on<LoadEvent>(_onLoad);
  }
  
  Future<void> _onLoad(LoadEvent event, Emitter<MyState> emit) async {
    // Cancel previous subscription if any
    await _streamSubscription?.cancel();
    
    // Create new subscription
    _streamSubscription = _repository.stream.listen(
      (data) {
        emit(MyState(data));
      },
      onError: (error) {
        emit(MyState.error(error.toString()));
      },
      cancelOnError: false, // Don't auto-cancel on error
    );
  }
  
  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    return super.close();
  }
}
```

---

## 4. Controller Disposal Pattern

### Pattern for TextEditingController, AnimationController, ScrollController

**✅ CORRECT - Proper controller disposal:**
```dart
class MyScreenState extends State<MyScreen> {
  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late AnimationController _slideAnimation;
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _slideAnimation = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _scrollController = ScrollController();
  }
  
  @override
  void dispose() {
    // Dispose in reverse order of creation (good practice)
    _scrollController.dispose();
    _slideAnimation.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
```

---

## 5. Focus Node Cleanup Pattern

**✅ CORRECT - Focus node disposal:**
```dart
class FormScreenState extends State<FormScreen> {
  late FocusNode _titleFocusNode;
  late FocusNode _descriptionFocusNode;
  
  @override
  void initState() {
    super.initState();
    _titleFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
  }
  
  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }
}
```

---

## 6. Device Feature Cleanup Pattern

### Pattern for Features like Wakelock, Biometrics, etc.

**✅ CORRECT - Wakelock cleanup:**
```dart
class FocusSessionScreen extends StatefulWidget {
  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  @override
  void initState() {
    super.initState();
    // Enable wakelock during focus session
    WakelockPlus.enable();
  }
  
  @override
  void dispose() {
    // Restore normal screen lock behavior
    WakelockPlus.disable();
    super.dispose();
  }
}
```

**✅ CORRECT - Biometric cleanup:**
```dart
class AuthenticationScreen extends StatefulWidget {
  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  late LocalAuthentication _auth;
  
  @override
  void initState() {
    super.initState();
    _auth = LocalAuthentication();
  }
  
  @override
  void dispose() {
    // Stop any pending biometric authentication
    _auth.stopAuthentication();
    super.dispose();
  }
}
```

---

## 7. BlocProvider Usage Pattern

### Pattern for Providing BLoCs which triggers lifecycle

**✅ CORRECT - Using DI for BLoC instantiation:**
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MyBloc>(
          create: (_) => getIt<MyBloc>(),
              ..add(LoadEvent()), // Dispatch initial event
        ),
        BlocProvider<AnotherBloc>(
          create: (_) => getIt<AnotherBloc>(),
        ),
      ],
      child: const AppRouterWidget(),
    );
  }
}
```

**Key Points:**
- BLoC is created fresh for each MultiBlocProvider instance
- If using Singleton in getIt, same instance is reused
- If using Factory in getIt, new instance is created each time
- close() is called automatically when BlocProvider is removed from tree

---

## 8. Service Lifecycle Integration

### Pattern for connecting service cleanup to app lifecycle

**✅ CORRECT - App-wide lifecycle handling:**
```dart
// In main.dart
void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup service locator (with singletons)
  await setupServiceLocator();
  
  // Attach lifecycle observer
  WidgetsBinding.instance.addObserver(_AppLifecycleObserver());
  
  runApp(const MyApp());
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // App is about to be terminated - cleanup singletons
      getIt<VoiceCommandService>().dispose();
      getIt<BiometricAuthService>().dispose();
      // etc...
    }
  }
}
```

---

## 9. Timer Cleanup Pattern

### Pattern for any Timer/Ticker

**✅ CORRECT - Timer cleanup:**
```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  Timer? _debounceTimer;
  
  MyBloc() : super(MyInitial()) {
    on<SearchEvent>(_onSearch);
  }
  
  Future<void> _onSearch(SearchEvent event, Emitter<MyState> emit) async {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Start new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Perform search
      _performSearch(event.query);
    });
  }
  
  @override
  Future<void> close() async {
    _debounceTimer?.cancel();
    return super.close();
  }
}
```

---

## 10. Common Pitfalls & Solutions

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Uncancelled StreamSubscription | Memory leak, continued listening | Call `await subscription?.cancel()` in `close()` |
| Undisposed Controller | Memory leak, lingering listeners | Call `controller.dispose()` in `dispose()` |
| Undisposed FocusNode | Memory leak, hanging focus | Call `focusNode.dispose()` in `dispose()` |
| Timer not cancelled | Memory leak, delayed callbacks | Call `timer?.cancel()` in `close()` / `dispose()` |
| Side effects in build() | Rebuilds triggered repeatedly | Move to `initState()` only |
| Service cleanup not called | App-wide singletons never freed | Add lifecycle observer for `AppLifecycleState.detached` |
| Missing super.close()/dispose() | Parent cleanup skipped | Always call `super.close()` / `super.dispose()` at **END** |

---

## 11. Checklist for New Code

When creating a new BLoC or Screen:

- [ ] Identified all resources (subscriptions, controllers, services)
- [ ] Added close() override in BLoC with ALL resource cleanup
- [ ] Added dispose() override in StatefulWidget
- [ ] Cancelled all StreamSubscriptions
- [ ] Disposed all Controllers (TextEditingController, AnimationController, etc.)
- [ ] Disposed all FocusNodes
- [ ] Cleaned up device features (Wakelock, etc.)
- [ ] Called super.close() / super.dispose() at the end
- [ ] No side effects in build() method
- [ ] For screens with device features, cleanup immediately

---

## 12. Testing Cleanup

**How to verify proper cleanup:**

1. **Manual Testing:**
   - Open screen → close screen → no lingering effects
   - Trigger stream → leave screen → stream cancelled (check logs)
   - Enable wakelock → exit screen → screen sleeps normally

2. **Debug Logging:**
```dart
@override
Future<void> close() async {
  AppLogger.i('ℹ️ MyBloc: Closing and cleaning up resources...');
  await _subscription?.cancel();
  AppLogger.i('✅ MyBloc: Cleanup complete');
  return super.close();
}
```

3. **Memory Profiling:**
   - Use Flutter DevTools Memory tab
   - Navigate through screens
   - Check memory increases/decreases appropriately

---

## 13. Current Implementation Status

### ✅ CORRECTLY IMPLEMENTED (11 items)
- FocusBloc timer cleanup
- PomodoroBloc timer cleanup
- PomodoroTimerBloc timer cleanup
- AlarmsBloc periodic timer cleanup
- AudioRecorderBloc timer cleanup
- AudioPlaybackBloc stream subscription cleanup
- EnhancedNoteEditorScreen comprehensive dispose()
- GlobalSearchScreen proper dispose()
- VideoPlaybackBloc close() override (Session 20)
- NoteEditorBloc close() override (Session 20)
- FocusSessionScreen dispose() with Wakelock cleanup (Session 20)
- ReflectionHomeScreen dispose() (Session 20)
- VoiceCommandService dispose() method (Session 20)

### ⏳ TO BE AUDITED/STANDARDIZED
- All other BLoCs for consistent pattern
- All StatefulWidgets for property initialization/cleanup
- Service singletons for shutdown hooks

---

## References

- [Flutter BLoC Documentation](https://bloclibrary.dev)
- [Dart Streams API](https://dart.dev/tutorials/language/streams)
- [Flutter State Management Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)
