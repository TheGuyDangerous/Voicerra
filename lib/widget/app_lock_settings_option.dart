import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockSettingsOption extends StatefulWidget {
  const AppLockSettingsOption({
    Key? key,
    required LocalAuthentication auth,
  }) : _auth = auth, super(key: key);

  final LocalAuthentication _auth;

  @override
  State<AppLockSettingsOption> createState() => _AppLockSettingsOptionState();
}

class _AppLockSettingsOptionState extends State<AppLockSettingsOption> {

  bool _isDropDownActive = false;
  late final SharedPreferences _prefs;

  void getSharedPreferences() async{
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    getSharedPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {},
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xffd1ffeb),
              foregroundColor: Color(0xff006a53),
              child: Icon(Iconsax.lock),
            ),
            title: Text(
              'App Lock',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            subtitle: Text("Secure your notes"),
            trailing: InkWell(child: _isDropDownActive ? Icon(Icons.keyboard_arrow_up) : Icon(Icons.keyboard_arrow_down),
              onTap: (){
              setState((){
                _isDropDownActive = !_isDropDownActive;
              });
            },),
          ),
        ),
        if (_isDropDownActive)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Use Biometric", style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 11
              ),),
              Switch(
                activeColor: Color(0xffd1ffeb),
                onChanged: (value) async{
                if (value){
                  final bool didAuthenticate = await widget._auth.authenticate(
                      localizedReason: 'Please authenticate to set app lock',
                      options: const AuthenticationOptions(biometricOnly: true));
                  if (didAuthenticate){
                    await _prefs.setBool('isApplockActive', true);
                    setState((){});
                  }
                }
                else{
                  await _prefs.setBool('isApplockActive', false);
                  setState((){});
                }
              }, value: _prefs.getBool('isApplockActive') ?? false,)
            ],
          )
      ],
    );
  }
}
