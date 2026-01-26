# Error Handling Implementation Guide

## Overview
Comprehensive error handling has been implemented across the entire application with specific, user-friendly error messages. This document outlines the error handling strategy and conventions used.

## Error Handling Architecture

### Three-Layer Strategy

1. **Repository Layer** (Data Layer)
   - Throws specific exceptions with context-aware messages
   - Uses pattern: `throw Exception('Specific user-friendly message: $e')`
   - Re-throws custom exceptions using `on Exception { rethrow; }`

2. **BLoC Layer** (Presentation Logic)
   - Catches exceptions from repositories
   - Cleans error messages: `e.toString().replaceAll('Exception: ', '')`
   - Emits error states with cleaned messages

3. **UI Layer** (Widgets)
   - Listens to error states
   - Displays errors via SnackBar with appropriate styling
   - Uses 4-second duration for important errors
   - Color-codes errors (red) vs warnings (orange)

## Implementation Details

### Repository Error Messages

#### NoteRepositoryImpl
- `getNotes()`: "Unable to load notes from database: $e"
- `getNoteById()`: "Could not find note with ID $id: $e"
- `createNote()`: "Failed to save note. Please try again: $e"
- `updateNote()`: "Failed to update note. Changes not saved: $e"
- `deleteNote()`: "Could not delete note. Please try again: $e"

#### MediaRepositoryImpl
- Permission denied: "Photo library access denied. Please enable in device settings"
- No image selected: "No image was selected"
- No video selected: "No video was selected"
- Add image failure: "Failed to add image to note: $e"
- Remove media failure: "Could not remove media from note: $e"

#### ReflectionRepositoryImpl
- `getAllQuestions()`: "Unable to load reflection questions. Please try again: $e"
- `getQuestionsByCategory()`: "Could not load questions for category \"$category\": $e"
- `getQuestionById()`: "Could not find reflection question with ID \"$id\": $e"
- `addQuestion()`: "Failed to save custom question. Please try again: $e"
- `updateQuestion()`: "Could not update reflection question: $e"
- `deleteQuestion()`: "Could not delete question and associated answers: $e"
- `getAnswersByQuestion()`: "Unable to load answers for this question: $e"
- `getAllAnswers()`: "Unable to load reflection history: $e"
- `saveAnswer()`: "Failed to save your reflection. Please try again: $e"
- `saveDraft()`: "Could not save draft. Changes may be lost: $e"
- `getDraft()`: "Unable to load saved draft: $e"
- `deleteDraft()`: "Could not delete draft: $e"
- `getAnswerCountForToday()`: "Unable to count today's reflections: $e"

### Service Error Messages

#### BiometricAuthService
- Not available: "Biometric authentication not available on this device"
- Not enrolled: "No biometric credentials enrolled. Please set up fingerprint/face in device settings"
- Locked out: "Too many failed attempts. Please try again later"
- Permanently locked: "Biometric authentication permanently locked. Please unlock device first"
- Enable failed: "Could not enable biometric lock: $e"
- Disable failed: "Could not disable biometric lock: $e"

#### NotificationService
- Init failed: "Failed to initialize notifications. Please check notification permissions: $e"
- Past time: "Cannot schedule reminder for a past time. Please choose a future time"
- Schedule failed: "Could not schedule reminder. Please check notification settings: $e"
- Cancel failed: "Could not cancel reminder notification: $e"
- Cancel all failed: "Could not cancel all notifications: $e"

#### Image/Video Compression
- Image compression: "Could not compress image. File may be corrupted: $e"
- Video compression: "Could not compress video. File may be too large or corrupted: $e"

### BLoC Error Handling Pattern

All BLoCs now use this pattern:

```dart
try {
  // Operation logic
  await repository.someOperation();
  emit(SuccessState(...));
} catch (e) {
  final errorMsg = e.toString().replaceAll('Exception: ', '');
  emit(ErrorState(errorMsg));
}
```

**Updated BLoCs:**
- ✅ NoteBloc (5 operations)
- ✅ MediaBloc (9 operations)
- ✅ ReflectionBloc (11 operations)
- ✅ AlarmBloc (3 operations)
- ✅ TodoBloc (6 operations)

### UI Error Display

#### SnackBar Pattern
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(errorMessage),
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 4),
  ),
);
```

#### BlocListener Pattern
```dart
BlocListener<SomeBloc, SomeState>(
  listener: (context, state) {
    if (state is ErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  },
  child: // UI widgets
)
```

## Error Message Guidelines

### Message Characteristics
1. **User-Friendly**: Avoid technical jargon
2. **Actionable**: Suggest next steps when possible
3. **Specific**: Explain what went wrong
4. **Context-Aware**: Include relevant IDs or parameters
5. **Concise**: Keep messages brief (1-2 sentences)

### Examples of Good Messages
✅ "Photo library access denied. Please enable in device settings"
✅ "Cannot schedule reminder for a past time. Please choose a future time"
✅ "No biometric credentials enrolled. Please set up fingerprint/face in device settings"

### Examples of Bad Messages
❌ "Error occurred"
❌ "Failed"
❌ "Exception: null pointer"

## Testing Error Handling

### Manual Testing Checklist
- [ ] Test each repository operation with invalid data
- [ ] Test permission denials (photos, biometrics, notifications)
- [ ] Test network failures (if applicable)
- [ ] Test database corruption scenarios
- [ ] Verify error messages display correctly in UI
- [ ] Confirm error messages are user-friendly
- [ ] Check error message duration and styling

### Common Error Scenarios
1. **Database Errors**: Wrong IDs, missing records
2. **Permission Errors**: Camera, photos, biometrics denied
3. **Validation Errors**: Invalid dates, empty required fields
4. **Platform Errors**: Biometric not available/enrolled
5. **File System Errors**: Missing files, corruption

## Future Improvements

### Potential Enhancements
1. Error logging to file/service
2. Error analytics/tracking
3. Retry mechanisms for transient failures
4. Offline error handling
5. Error recovery suggestions
6. Multilingual error messages

### Monitoring
- Track error frequency
- Identify common error patterns
- Monitor user-reported issues
- Analyze error messages for clarity

## Maintenance

### When Adding New Features
1. Add specific error messages to repository methods
2. Handle errors in BLoC with clean message pattern
3. Display errors in UI with appropriate styling
4. Test error scenarios thoroughly
5. Update this documentation

### Code Review Checklist
- [ ] All repository methods have error handling
- [ ] Error messages are user-friendly
- [ ] BLoCs clean error messages before emitting
- [ ] UI displays errors appropriately
- [ ] Error messages suggest next steps
- [ ] No generic "Failed" or "Error" messages

## Summary

The app now has comprehensive error handling with:
- **34+ specific error messages** across all repositories
- **34+ BLoC error handlers** with message cleaning
- **Consistent UI error display** patterns
- **User-friendly, actionable** error messages
- **Proper exception propagation** from data to UI layer

All error handling follows the three-layer strategy, ensuring users receive meaningful feedback when something goes wrong.
