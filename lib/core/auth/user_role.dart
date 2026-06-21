/// User roles in the Vanthenda Paalkaran system.
enum UserRole {
  /// Full access — manages everything.
  vendor,

  /// Read-only access to own milk card, bills, payments, and requests.
  customer,

  /// Access to today's delivery route only.
  staff,

  /// Role not yet determined (new user, pending setup).
  unknown,
}
