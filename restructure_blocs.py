import os
import shutil

base_path = r"F:\GitHub\mynotes\lib\presentation\bloc"

# Feature to files mapping (simplified)
# We will look for files starting with the feature name and move them to the feature folder.
# Except for some that have special names like 'note_bloc' instead of 'notes_bloc'.

exclude_dirs = ["activitytag", "alarm", "color", "params", "media_viewer", "calendar_integration", "note", "note_editor", "todo", "todos", "navigation", "search", "drawing_canvas", "media_gallery", "media_picker", "smart_collections", "smart_reminders", "unified_items", "reminder_templates", "rule_builder", "settings", "theme", "biometric_auth"]

# Get all files in the base path
files = [f for f in os.listdir(base_path) if os.path.isfile(os.path.join(base_path, f))]

# Group files by their prefix (everything before the last '_')
groups = {}
for f in files:
    if f == "BLOC_ERROR_HANDLING_PATTERNS.dart": continue
    
    # Try to find a logical feature name
    # e.g., 'accessibility_features_bloc.dart' -> 'accessibility_features'
    # e.g., 'note_bloc.dart' -> 'note'
    
    parts = f.split('_')
    if len(parts) > 1:
        # Check if it ends with 'bloc.dart', 'event.dart', 'state.dart'
        if f.endswith('_bloc.dart') or f.endswith('_event.dart') or f.endswith('_state.dart'):
             feature = '_'.join(parts[:-1])
        else:
             feature = parts[0]
    else:
        # e.g., 'notes.dart' (if any)
        feature = f.split('.')[0]

    if feature not in groups:
        groups[feature] = []
    groups[feature].append(f)

# Handle some manual groups
if 'note' in groups and 'note_editor' in groups:
    # They are already separated
    pass

for feature, f_list in groups.items():
    feature_dir = os.path.join(base_path, feature)
    if not os.path.exists(feature_dir):
        os.makedirs(feature_dir)
    
    for f in f_list:
        try:
            shutil.move(os.path.join(base_path, f), os.path.join(feature_dir, f))
            print(f"Moved {f} to {feature}/")
        except Exception as e:
            print(f"Error moving {f}: {e}")
