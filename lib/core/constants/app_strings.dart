/// All hardcoded strings used throughout the app
/// Centralized for easy maintenance and localization
class AppStrings {
  AppStrings._();

  // ═════════════════════════════════════════════════════════════════════════
  // GENERAL
  // ═════════════════════════════════════════════════════════════════════════

  static const String appName = 'MyNotes';
  static const String appVersion = '1.0.0';

  // ═════════════════════════════════════════════════════════════════════════
  // COMMON ACTIONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String create = 'Create';
  static const String update = 'Update';
  static const String remove = 'Remove';
  static const String close = 'Close';
  static const String done = 'Done';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String confirm = 'Confirm';
  static const String retry = 'Retry';
  static const String back = 'Back';
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String finish = 'Finish';
  static const String more = 'More';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String export = 'Export';
  static const String import_ = 'Import';
  static const String share = 'Share';
  static const String copy = 'Copy';
  static const String paste = 'Paste';
  static const String cut = 'Cut';
  static const String selectAll = 'Select All';
  static const String deselect = 'Deselect';

  // ═════════════════════════════════════════════════════════════════════════
  // NOTES
  // ═════════════════════════════════════════════════════════════════════════

  static const String notes = 'Notes';
  static const String myNotes = 'My Notes';
  static const String newNote = 'New Note';
  static const String createNote = 'Create Note';
  static const String editNote = 'Edit Note';
  static const String deleteNote = 'Delete Note';
  static const String noteTitle = 'Note Title';
  static const String noteContent = 'Note Content';
  static const String noNotes = 'No Notes';
  static const String noNotesAvailable =
      'No notes available. Create your first note!';
  static const String archiveNote = 'Archive Note';
  static const String unarchiveNote = 'Unarchive Note';
  static const String pinNote = 'Pin Note';
  static const String unpinNote = 'Unpin Note';
  static const String addLabel = 'Add Label';
  static const String addColor = 'Add Color';
  static const String addTag = 'Add Tag';
  static const String bold = 'Bold';
  static const String italic = 'Italic';
  static const String underline = 'Underline';
  static const String bulletPoint = 'Bullet Point';
  static const String numberedPoint = 'Numbered Point';
  static const String created = 'Created';
  static const String updated = 'Updated';
  static const String words = 'Words';
  static const String characters = 'Characters';
  static const String links = 'Links';
  static const String pinned = 'Pinned';
  static const String archived = 'Archived';
  static const String favorite = 'Favorite';

  // ═════════════════════════════════════════════════════════════════════════
  // TODOS
  // ═════════════════════════════════════════════════════════════════════════

  static const String todos = 'Todos';
  static const String myTodos = 'My Todos';
  static const String newTodo = 'New Todo';
  static const String createTodo = 'Create Todo';
  static const String editTodo = 'Edit Todo';
  static const String deleteTodo = 'Delete Todo';
  static const String todoTitle = 'Todo Title';
  static const String todoDescription = 'Todo Description';
  static const String noTodos = 'No Todos';
  static const String noTodosAvailable =
      'No todos available. Create your first todo!';
  static const String markComplete = 'Mark Complete';
  static const String markIncomplete = 'Mark Incomplete';
  static const String addSubtask = 'Add Subtask';
  static const String priority = 'Priority';
  static const String dueDate = 'Due Date';
  static const String category = 'Category';
  static const String highPriority = 'High Priority';
  static const String mediumPriority = 'Medium Priority';
  static const String lowPriority = 'Low Priority';
  static const String urgentPriority = 'Urgent Priority';

  // ═════════════════════════════════════════════════════════════════════════
  // ALARMS & REMINDERS
  // ═════════════════════════════════════════════════════════════════════════

  static const String alarms = 'Alarms';
  static const String reminders = 'Reminders';
  static const String newAlarm = 'New Alarm';
  static const String createAlarm = 'Create Alarm';
  static const String editAlarm = 'Edit Alarm';
  static const String deleteAlarm = 'Delete Alarm';
  static const String alarmTime = 'Alarm Time';
  static const String alarmLabel = 'Alarm Label';
  static const String snooze = 'Snooze';
  static const String dismiss = 'Dismiss';
  static const String repeat = 'Repeat';
  static const String repeatDaily = 'Repeat Daily';
  static const String repeatWeekly = 'Repeat Weekly';
  static const String repeatMonthly = 'Repeat Monthly';
  static const String repeatYearly = 'Repeat Yearly';
  static const String selectDays = 'Select Days';
  static const String customDays = 'Custom Days';
  static const String alarmSound = 'Alarm Sound';
  static const String vibration = 'Vibration';
  static const String enable = 'Enable';
  static const String disable = 'Disable';

  // ═════════════════════════════════════════════════════════════════════════
  // MEDIA
  // ═════════════════════════════════════════════════════════════════════════

  static const String media = 'Media';
  static const String gallery = 'Gallery';
  static const String camera = 'Camera';
  static const String video = 'Video';
  static const String audio = 'Audio';
  static const String document = 'Document';
  static const String uploadImage = 'Upload Image';
  static const String takePhoto = 'Take Photo';
  static const String recordVideo = 'Record Video';
  static const String recordAudio = 'Record Audio';
  static const String selectFromGallery = 'Select from Gallery';
  static const String mediaAdded = 'Media Added';
  static const String mediaRemoved = 'Media Removed';

  // ═════════════════════════════════════════════════════════════════════════
  // SEARCH & FILTERS
  // ═════════════════════════════════════════════════════════════════════════

  static const String searchNotes = 'Search Notes';
  static const String searchTodos = 'Search Todos';
  static const String noResults = 'No Results';
  static const String noSearchResults = 'No results found for your search';
  static const String advanced = 'Advanced';
  static const String advancedFilters = 'Advanced Filters';
  static const String clearFilters = 'Clear Filters';
  static const String applyFilters = 'Apply Filters';
  static const String filterByDate = 'Filter by Date';
  static const String filterByTag = 'Filter by Tag';
  static const String filterByColor = 'Filter by Color';
  static const String filterByStatus = 'Filter by Status';

  // ═════════════════════════════════════════════════════════════════════════
  // SETTINGS
  // ═════════════════════════════════════════════════════════════════════════

  static const String settings = 'Settings';
  static const String account = 'Account';
  static const String appearance = 'Appearance';
  static const String theme = 'Theme';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  static const String language = 'Language';
  static const String notifications = 'Notifications';
  static const String privacy = 'Privacy';
  static const String about = 'About';
  static const String version = 'Version';
  static const String help = 'Help';
  static const String feedback = 'Feedback';
  static const String logout = 'Logout';
  static const String deleteAccount = 'Delete Account';

  // ═════════════════════════════════════════════════════════════════════════
  // VALIDATION & ERRORS
  // ═════════════════════════════════════════════════════════════════════════

  static const String required = 'This field is required';
  static const String invalidEmail = 'Invalid email address';
  static const String invalidPhone = 'Invalid phone number';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String error = 'Error';
  static const String errorOccurred = 'An error occurred';
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Please try again';
  static const String loading = 'Loading...';
  static const String noInternet = 'No Internet Connection';
  static const String noInternetDescription =
      'Please check your internet connection and try again';
  static const String serverError = 'Server Error';
  static const String serverErrorDescription =
      'The server encountered an error. Please try again later';
  static const String notFound = 'Not Found';
  static const String unauthorized = 'Unauthorized';
  static const String forbidden = 'Forbidden';

  // ═════════════════════════════════════════════════════════════════════════
  // SUCCESS MESSAGES
  // ═════════════════════════════════════════════════════════════════════════

  static const String success = 'Success';
  static const String noteSaved = 'Note saved successfully';
  static const String noteDeleted = 'Note deleted successfully';
  static const String todoSaved = 'Todo saved successfully';
  static const String todoDeleted = 'Todo deleted successfully';
  static const String alarmSet = 'Alarm set successfully';
  static const String alarmDeleted = 'Alarm deleted successfully';
  static const String settingsSaved = 'Settings saved successfully';
  static const String changesSaved = 'Changes saved successfully';
  static const String copiedToClipboard = 'Copied to clipboard';
  static const String sharedSuccessfully = 'Shared successfully';

  // ═════════════════════════════════════════════════════════════════════════
  // DIALOGS & CONFIRMATIONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String confirmDelete = 'Confirm Delete';
  static const String confirmDeleteMessage =
      'Are you sure you want to delete this item? This action cannot be undone.';
  static const String confirmLogout = 'Confirm Logout';
  static const String confirmLogoutMessage = 'Are you sure you want to logout?';
  static const String discardChanges = 'Discard Changes';
  static const String discardChangesMessage =
      'You have unsaved changes. Do you want to discard them?';

  // ═════════════════════════════════════════════════════════════════════════
  // PLACEHOLDERS
  // ═════════════════════════════════════════════════════════════════════════

  static const String enterText = 'Enter text';
  static const String typeHere = 'Type here...';
  static const String selectDate = 'Select date';
  static const String selectTime = 'Select time';
  static const String addMore = 'Add more';
  static const String noData = 'No data';
  static const String empty = 'Empty';
  static const String loading2 = 'Loading...';
  static const String retrying = 'Retrying...';

  static String get untitledNote => "Untitled Note";
}
