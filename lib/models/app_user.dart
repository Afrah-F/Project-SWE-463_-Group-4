/// The signed-in account. The password is never part of this model.
class AppUser {
  final String uid;
  final String name;
  final String email;

  const AppUser({required this.uid, required this.name, required this.email});

  AppUser copyWith({String? name}) =>
      AppUser(uid: uid, name: name ?? this.name, email: email);
}
