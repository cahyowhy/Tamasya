import 'package:tamasya/model/base_model.dart';

class UserAuth extends BaseModel {
  String type;
  String username;
  String applicationName;
  String clientId;
  String tokenType;
  String accessToken;
  int expiresIn;
  String state;
  String scope;
  int willExpiresAt;

  UserAuth(
      {this.type,
      this.username,
      this.applicationName,
      this.clientId,
      this.tokenType,
      this.accessToken,
      this.expiresIn,
      this.state,
      this.scope});

  fromJson(json) {
    return UserAuth.fromJson(json);
  }

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    UserAuth userAuth = UserAuth(
        type: json['type'],
        username: json['username'],
        applicationName: json['application_name'],
        clientId: json['client_id'],
        tokenType: json['token_type'],
        accessToken: json['access_token'],
        expiresIn: json['expires_in'],
        state: json['state'],
        scope: json['scope']);

    if ((userAuth.expiresIn ?? 0) > 0) {
      userAuth.willExpiresAt = DateTime.now()
          .add(Duration(seconds: userAuth.expiresIn))
          .millisecondsSinceEpoch;
    }

    return userAuth;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['username'] = this.username;
    data['application_name'] = this.applicationName;
    data['client_id'] = this.clientId;
    data['token_type'] = this.tokenType;
    data['access_token'] = this.accessToken;
    data['expires_in'] = this.expiresIn;
    data['state'] = this.state;
    data['scope'] = this.scope;
    data['willExpiresAt'] = this.willExpiresAt;

    return data;
  }
}
