import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// AppSync cloud config
const _awsUserPoolId = 'us-east-1_xxxxxxxx';
const _awsClientId = '2d7eoqt5k7180165oxxxxxxxxl';
const _identityPoolId = 'us-east-1:c2a7c651-3dc3-42e7-9bec-xxxxxxxxxxxx';
const _endpoint = 'https://w2fpmtxd3vbhtgdkexxxxxxxx.appsync-api.us-east-1.amazonaws.com/graphql';

// Extend CognitoStorage with Shared Preferences to persist account
// login sessions
class Storage extends CognitoStorage {
  final SharedPreferences _prefs;
  Storage(this._prefs);

  @override
  Future getItem(String key) async {
    String item;
    try {
      item = json.decode(_prefs.getString(key) ?? '');
    } catch (e) {
      return null;
    }
    return item;
  }

  @override
  Future setItem(String key, value) async {
    _prefs.setString(key, json.encode(value));
    return getItem(key);
  }

  @override
  Future removeItem(String key) async {
    final item = getItem(key);
    _prefs.remove(key);
    return item;
  }

  @override
  Future<void> clear() async {
    _prefs.clear();
  }
}

class User {
  String? email;
  String? firstname;
  String? lastname;
  String? password;
  String? birthdate;
  bool confirmed = false;
  bool hasAccess = false;

  User({this.email, this.firstname, this.lastname});

  /// Decode user from Cognito User Attributes
  factory User.fromUserAttributes(List<CognitoUserAttribute> attributes) {
    final user = User();
    for (CognitoUserAttribute attribute in attributes) {
      if (attribute.getName() == 'email') {
        user.email = attribute.getValue()!;
      } else if (attribute.getName() == 'firstname') {
        user.firstname = attribute.getValue()!;
      } else if (attribute.getName() == 'lastname') {
        user.lastname = attribute.getValue()!;
      } else if (attribute.getName() == 'birthdate') {
        user.birthdate = attribute.getValue()!;
      }
    }
    return user;
  }
}

class CloudConnectivity {
  CognitoUserPool? _userPool;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;
  CognitoCredentials? _credentials;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> init() async {
    _userPool = CognitoUserPool(_awsUserPoolId, _awsClientId);
    bool valid = false;
    SharedPreferences prefs = await _prefs;
    final storage = Storage(prefs);
    _userPool?.storage = storage;

    try {
      _cognitoUser = await _userPool?.getCurrentUser();
      if (_cognitoUser == null) {
        return false;
      }

      _session = await _cognitoUser?.getSession();
      if (_session != null) {
        valid = _session!.isValid();
      }
    } catch (e) {
      valid = false;
    }

    return valid;
  }

  Future signOut() async {
    if (_credentials != null) {
      await _credentials!.resetAwsCredentials();
    }
    if (_session != null) {
      _session!.invalidateToken();
    }
    if (_cognitoUser != null) {
      _cognitoUser!.signOut();
    }
    return;
  }

  Future signIn(String username, String password) async {
    _cognitoUser = CognitoUser(username, _userPool!);
    final authDetails = AuthenticationDetails(username: username, password: password);

    try {
      _session = (await _cognitoUser!.authenticateUser(authDetails))!;
    } catch (e) {
      return;
    }
  }

  // Retrieve user credentials -- for use with other AWS services
  Future<CognitoCredentials?> getCredentials() async {
    try {
      if (!_session!.isValid()) {
        _session = await _cognitoUser!.getSession();
      }

      if (_cognitoUser == null || _session == null) {
        return null;
      }
      _credentials = CognitoCredentials(_identityPoolId, _userPool!);
      if (_session!.getIdToken().getExpiration() < ((DateTime
          .now()
          .millisecondsSinceEpoch / 1000) + 10)) {
        await _credentials!.getAwsCredentials(
            _session!.getIdToken().getJwtToken());
      }
    } catch (e) {
      _credentials = null;
    }

    return _credentials;
  }

  Future<String> query(String query) async {
    String resp = '';
    if (_session != null) {
      final httpHeaders = {
        HttpHeaders.authorizationHeader: _session!.getIdToken().getJwtToken()!,
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
      };

      final requestBody = jsonEncode({
        "query": query});

      http.Response response;
      try {
        response = await http.post(
            Uri.parse(_endpoint),
            headers: httpHeaders,
            body: requestBody
        );
        resp = response.body;
      } catch (e) {
        resp = '';
      }
    }

    return resp;
  }


  Future<List> signUp(String email, String password, String firstname, String lastname) async {
    CognitoUserPoolData data;

    final userAttributes = [
      AttributeArg(name: 'custom:firstname', value: firstname),
      AttributeArg(name: 'custom:lastname', value: lastname),
    ];

    String message = '';
    bool success = false;
    try {
      data = await _userPool!.signUp(email, password, userAttributes: userAttributes);
      success = data.userSub != '';

      message = 'User sign up successful, please verify your email address by clinking on the link in email sent to address ' + email;
    } on CognitoClientException catch (e) {
      if (e.code == 'UsernameExistsException') {
        message = 'Email address is already in use';
      } else if (e.code == 'ResourceNotFoundException') {
        message = 'Internet connection not available';
      } else {
        message = 'Sign Up error, please try again later';
      }
    } catch (e) {
      message = 'Sign Up error, please try again later';
    }

    return [success, message];
  }

  Future<String> forgotPassword(String email) async {
    String message = 'A password reset code has been sent to your email, enter the code and your new password in the next page';
    try {
      final cognitoUser = CognitoUser(email, _userPool!);
      await cognitoUser.forgotPassword();
    } on CognitoClientException catch (e) {
      if (e.code == 'ResourceNotFoundException') {
        message = 'Internet connection not available';
      } else {
        message = 'Password reset error, please try again later';
      }
    } catch (e) {
      message = 'Password reset error, please try again later';
    }
    return message;
  }

  Future<List> forgotPasswordSetNew(String email, String resetCode, String password) async {
    String message = '';
    bool success = false;
    try {
      final cognitoUser = CognitoUser(email, _userPool!);
      if (await cognitoUser.confirmPassword(resetCode, password)) {
        success = true;
        message = 'Your password has been reset';
      } else {
        message = 'Password reset error, please try again later';
      }
    } on CognitoClientException catch (e) {
      if (e.code == 'ResourceNotFoundException') {
        message = 'Internet connection not available';
      } else if (e.code == 'ExpiredCodeException') {
        message = 'The reset password code you entered has expired';
      } else if (e.code == 'LimitExceededException') {
        message = 'You have reached the limit for retries, please try again in 1 hour';
      } else if (e.code == 'CodeMismatchException') {
        message = 'The reset password code you entered is incorrect';
      } else {
        message = 'Password reset error, please try again later';
      }
    } catch (e) {
      message = 'Password reset error, please try again later';
    }

    return [success, message];
  }

  Future<List> changePassword(String oldPassword, String newPassword) async {
    String message = '';
    bool success = false;

    try {
      if (await _cognitoUser!.changePassword(oldPassword, newPassword)) {
        success = true;
        message = 'Your password has been updated';
      }
    } on CognitoClientException catch (e) {
      if (e.code == 'NotAuthorizedException') {
        message = 'The current password you entered is incorrect';
      } else if (e.code == 'ResourceNotFoundException') {
        message = 'Internet connection not available';
      } else if (e.code == 'LimitExceededException') {
        message = 'You have reached the limit for retries, please try again in 1 hour';
      }
    } catch (e) {
      message = 'Password reset error, please try again later';
    }

    return [success, message];
  }

  Future<User?> getCurrentUser() async {
    if (_cognitoUser == null || _session == null) {
      return null;
    }
    if (!_session!.isValid()) {
      return null;
    }
    final attributes = await _cognitoUser?.getUserAttributes();
    if (attributes == null) {
      return null;
    }
    final user = User.fromUserAttributes(attributes);
    user.hasAccess = true;
    return user;
  }

  bool checkAuthenticatedSync() {
    bool valid = false;
    if (_session != null) {
      if (_cognitoUser != null) {
        valid = _session!.isValid();
      }
    }
    return valid;
  }

}