import 'package:firebase_auth/firebase_auth.dart';

FirebaseUser _user;
bool isSignedIn;
bool isVerified;
String uid;

Future getUserStatus() async {
  FirebaseAuth.instance.currentUser().then((user) {
    _user = user;
    if (user == null) {
      isSignedIn = false;
    } else {
      isSignedIn = true;
      //uid = user.uid;
    }
  });
}

void setUser(FirebaseUser user) {
  _user = user;
}

void setUserSignedIn() {
  isSignedIn = true;
}

void setUserSignedOut() {
  isSignedIn = false;
}

bool userIsSignedIn() {
  return isSignedIn;
}

void reloadUser() async {
  await _user.reload();
}

void setUserIsVerified() {
  isVerified = true;
}

bool userIsVerified() {
  if (isVerified == null) {
    return _user.isEmailVerified;
  }

  return isVerified;
}

String getUID() {
  if (_user != null) {
    return _user.uid;
  } else {
    return "";
  }
}

FirebaseUser getUser() {
  return _user;
}
