# Architecture rules

> Paste or attach this file every time you ask Claude to change the project,
> so new code follows the same structure.

Photo Swipe is a Flutter app (Dart). Everything stays on the phone: no server,
no account. Photos are never copied; the app only remembers *which photo id*
was kept or trashed.

## Folder map

```
lib/
├── main.dart            Starts the app. Nothing else.
├── app.dart             Theme + "ask permission, then show Home".
├── core/                Shared basics: theme.dart, strings.dart, format.dart
├── models/              Plain data classes. No logic, no Flutter widgets.
├── data/                Everything that reads or writes data
│   ├── database/          app_database.dart (tables), *_dao.dart (queries)
│   ├── gallery_source.dart   The ONLY file that talks to the phone gallery
│   ├── photo_repository.dart The ONLY door the features use to get data
│   └── providers.dart        Wiring (Riverpod providers) for the data layer
├── shared/widgets/      Widgets used by more than one feature
└── features/            One folder per feature
    ├── permission/        Ask for gallery access
    ├── library/           Shared state: undecided / kept / trashed photos
    ├── swipe/             The swipe deck screen
    ├── trash/             Trash grid, restore, delete for good
    └── home/              Bottom tab bar that holds the screens
```

## The rules

1. **One feature = one folder.** A new feature gets a new folder under
   `features/`. Adding it should not require rewriting an old feature.
2. **Screens never touch the gallery or the database.** They read and change
   data through `PhotoRepository` (via a controller in `features/library`).
   If the gallery package or the database changes, only `data/` changes.
3. **Only `gallery_source.dart` imports `photo_manager`.** Only
   `app_database.dart` and the `*_dao.dart` files import `sqflite`.
4. **Features do not import other features' widgets.** They may share:
   `core/`, `models/`, `data/`, `shared/widgets/`, and `features/library/`
   (the shared state). If two features need the same widget, move it to
   `shared/widgets/`.
5. **State lives in Riverpod controllers**, not inside screens. A screen
   *watches* a provider and *calls methods* on its controller. Screens
   keep only throw-away UI state (selected tab, animation position).
6. **One file, one job.** Aim for files under ~200 lines. If a file grows past
   that, split it.
7. **No user-facing text in widgets.** Add it to `core/strings.dart`.
8. **No hard-coded colors in screens.** Use `Theme.of(context)` or
   `AppColors` in `core/theme.dart`.
9. **Database changes need a version bump.** Add the new table/column in
   `app_database.dart` with an `onUpgrade` step so existing users keep their
   decisions.
10. **Tests and builds come from GitHub Actions**, not from the phone or
    Codespace.

## How data flows

```
Screen ──watches──▶ libraryProvider (LibraryController)
                         │ calls
                         ▼
                   PhotoRepository
                    │            │
                    ▼            ▼
             GallerySource   DecisionDao ──▶ AppDatabase (SQLite)
          (phone gallery)    (kept/trashed)
```

A swipe: `SwipeDeck` → `onSwiped` → `LibraryController.decide()` → state
updates immediately (screen redraws) → `PhotoRepository.saveDecision()` saves
to SQLite in the background.

## Where the next features go

| Feature                       | What to add                                                                 |
|-------------------------------|-----------------------------------------------------------------------------|
| Filter by month / album       | `features/filter/` + `GallerySource.loadAlbums()` + a filter provider that narrows `undecided` |
| Undo last swipe               | History list in `LibraryController` + a button in `swipe_action_buttons.dart` |
| Browse "kept" photos          | A new tab in `features/home/` + `features/kept/`                             |
| Photo count / storage stats   | `features/stats/`                                                            |

## Database

SQLite file `photo_swipe.db`, version 1.

Table `decisions`
| column      | type              | meaning                       |
|-------------|-------------------|-------------------------------|
| photo_id    | TEXT PRIMARY KEY  | The gallery's id for the photo |
| status      | TEXT              | `kept` or `trashed`            |
| decided_at  | INTEGER           | Milliseconds since 1970        |

A photo with no row has not been reviewed yet.
