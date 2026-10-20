/// Every piece of text the user sees lives here, so it is easy to find,
/// reword, or translate later.
class AppStrings {
  AppStrings._();

  static const appName = 'Photo Swipe';

  // Tabs
  static const tabSwipe = 'ปัดรูป';
  static const tabTrash = 'ถังขยะ';

  // Loading and errors
  static const checkingPermission = 'กำลังตรวจสอบสิทธิ์...';
  static const loadingLibrary = 'กำลังโหลดรูปจากเครื่อง...';
  static const loadFailed = 'โหลดรูปไม่สำเร็จ';
  static const retry = 'ลองอีกครั้ง';

  // Permission
  static const permissionTitle = 'ขออนุญาตเข้าถึงรูปภาพ';
  static const permissionMessage =
      'แอปต้องอ่านรูปในเครื่องของคุณเพื่อให้ปัดคัดรูปได้ '
      'รูปทั้งหมดอยู่ในเครื่อง ไม่มีการอัปโหลดไปที่ไหน\n\n'
      'ถ้าเคยกด "ไม่อนุญาต" ให้เปิดสิทธิ์ "รูปภาพ" '
      'ในหน้าตั้งค่าของแอป แล้วกลับมาที่นี่';
  static const permissionRetry = 'ขออนุญาตอีกครั้ง';
  static const permissionOpenSettings = 'เปิดการตั้งค่า';

  // Swipe screen
  static const keepLabel = 'เก็บ';
  static const trashLabel = 'ทิ้ง';
  static const doneTitle = 'ปัดครบทุกรูปแล้ว';
  static const doneOpenTrash = 'ไปที่ถังขยะ';
  static const emptyLibraryTitle = 'ไม่พบรูปในเครื่อง';
  static const emptyLibraryMessage = 'ลองถ่ายรูปสักใบ แล้วกลับมาใหม่';

  static String remaining(String count) => 'เหลืออีก $count รูป';

  static String doneSummary(String kept, String trashed) =>
      'เก็บไว้ $kept รูป · อยู่ในถังขยะ $trashed รูป';

  // Trash screen
  static const trashTitle = 'ถังขยะ';
  static const trashHint =
      'รูปที่ปัดซ้ายจะรออยู่ที่นี่ ยังไม่ถูกลบออกจากเครื่อง '
      'จนกว่าคุณจะกดล้างถังขยะ แตะรูปเพื่อดูหรือกู้คืน';
  static const trashEmpty = 'ถังขยะว่างเปล่า';
  static const emptyTrashButton = 'ล้างถังขยะ';
  static const emptyTrashConfirmTitle = 'ลบรูปถาวร?';
  static const cancel = 'ยกเลิก';
  static const confirmDelete = 'ลบถาวร';
  static const deleteCancelledSnack = 'ยังไม่ได้ลบรูป';
  static const deleteFailedSnack = 'ลบรูปไม่สำเร็จ ลองอีกครั้ง';
  static const restore = 'กู้คืน';
  static const close = 'ปิด';
  static const restoredSnack = 'กู้คืนแล้ว รูปนี้ถูกเก็บไว้';

  static String trashCount(String count) => '$count รูป';

  static String emptyTrashConfirmMessage(String count) =>
      'รูป $count ใบจะถูกลบออกจากเครื่องถาวร '
      'Android จะถามยืนยันอีกครั้ง และกู้คืนไม่ได้อีก';

  static String deletedSnack(String count) => 'ลบแล้ว $count รูป';
}
