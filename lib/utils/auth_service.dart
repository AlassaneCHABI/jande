import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:jande/utils/constants.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:jande/models/users.dart';
import 'db_manager.dart';


class AuthService {
  final String baseUrl = API_BASE_URL;
  PreferenceManager pref_manager = PreferenceManager();
  DbManager db_manager = DbManager();
  DateTime currDate = new DateTime.now();

  Future<String> loginToServer(user) async {
    final authUrl = API_BASE_URL + '/login';

    final http.Response response = await http.post(Uri.parse(authUrl),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user)
    );

    // print(response.body);
    var reponse_server = jsonDecode(response.body);
    var msg_server="";
    // print(reponse_server);

    if (response.statusCode == 200)
    {
      db_manager.removeAllDbUser();
      db_manager.insertDbUser(User.fromJson(reponse_server['data']));

      pref_manager.setFirstTime();
      pref_manager.setPrefItem('access_token',(reponse_server['access_token']).toString());
      pref_manager.setPrefItem('user_id',(reponse_server['data']['id']).toString());
      pref_manager.setPrefItem('role_id',(reponse_server['data']['role_id']).toString());
      pref_manager.setPrefItem('role_name',"user");
      pref_manager.setPrefItem('first_name',(reponse_server['data']['first_name']).toString());
      pref_manager.setPrefItem('last_name',(reponse_server['data']['last_name']).toString());
      pref_manager.setPrefItem('contact',(reponse_server['data']['contact']).toString());
      pref_manager.setPrefItem('email',(reponse_server['data']['email']).toString());
      pref_manager.setPrefItem('is_active',(reponse_server['data']['is_active']).toString());

      msg_server = "succes***";
    }
    else {
      msg_server = reponse_server['message'];
    }
    return msg_server;
  }


  Future registerUserProfile(user) async {
    print("Nous sommes ici");
    final authUrl = API_BASE_URL + '/register';

    final http.Response response = await http.post(Uri.parse(authUrl),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user)
    );

    var reponse_server = jsonDecode(response.body);
    print("Le message du serveur");
    print(reponse_server['data']);
    var msg_server="";
    // print(reponse_server);

    if (response.statusCode == 200)
    {
      db_manager.removeAllDbUser();
      db_manager.insertDbUser(User.fromJson(reponse_server['data']));


      pref_manager.setPrefItem('access_token',(reponse_server['access_token']).toString());
      pref_manager.setPrefItem('user_id',(reponse_server['data']['id']).toString());
      pref_manager.setPrefItem('role_id',(reponse_server['data']['role_id']).toString());
      pref_manager.setPrefItem('role_name',"user");
      pref_manager.setPrefItem('first_name',(reponse_server['data']['first_name']).toString());
      pref_manager.setPrefItem('last_name',(reponse_server['data']['last_name']).toString());
      pref_manager.setPrefItem('contact',(reponse_server['data']['contact']).toString());
      pref_manager.setPrefItem('email',(reponse_server['data']['email']).toString());
      pref_manager.setPrefItem('is_active',(reponse_server['data']['is_active']).toString());

      msg_server = "succes";
    }
    else {
      msg_server = reponse_server['message'];
    }
    return msg_server;
  }

}
