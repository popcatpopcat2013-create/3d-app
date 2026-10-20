/// What the user decided about a photo. A photo with no decision is
/// simply "not reviewed yet" and has no row in the database.
enum PhotoStatus {
  kept,
  trashed;

  /// The text stored in the database.
  String get dbValue => name;

  static PhotoStatus fromDb(String value) => PhotoStatus.values.byName(value);
}
