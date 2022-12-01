import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:voicerra/widget/customappbar.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    getAppInfo();
    _initPackageInfo();
    super.initState();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(),
              ),
              padding: const EdgeInsets.all(10),
              child: ListView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                children: [
                  MyAppBar(
                    title: 'Settings',
                    onIconTap: _version,
                    iconName: Iconsax.cpu,
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () {},
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xffd1ffeb),
                        foregroundColor: Color(0xff006a53),
                        child: Icon(Iconsax.cpu),
                      ),
                      title: Text(
                        'App Version',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      subtitle: Text(_packageInfo.version),
                    ),
                  ),
                  Column(
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
                          trailing: Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Use Biometric", style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 11
                          ),),
                          Switch(onChanged: (value){}, value: false,)
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        'Contributors',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () async {
                      const url = 'https://www.linkedin.com/in/sannidhyadubey';
                      if (await launchUrlString(url)) {
                        await launchUrlString(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xffd1ffeb),
                        foregroundColor: Color(0xff006a53),
                        child: Icon(Iconsax.user),
                      ),
                      title: Text(
                        'Sannidhya Dubey',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      subtitle: Text(
                        'Lead Dev & App Design',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () async {
                      const url = 'https://www.linkedin.com/in/roy15';
                      if (await launchUrlString(url)) {
                        await launchUrlString(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xffd1ffeb),
                        foregroundColor: Color(0xff006a53),
                        child: Icon(Iconsax.user),
                      ),
                      title: Text(
                        'Bishal Roy',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      subtitle: Text(
                        'Lead Designer',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () async {
                      const url =
                          'https://www.linkedin.com/in/sneha-soni-918224236';
                      if (await launchUrlString(url)) {
                        await launchUrlString(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xffd1ffeb),
                        foregroundColor: Color(0xff006a53),
                        child: Icon(Iconsax.user),
                      ),
                      title: Text(
                        'Sneha Soni',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      subtitle: Text(
                        'Lead Design and Doccumentation',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: null,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xffd1ffeb),
                        foregroundColor: Color(0xff006a53),
                        child: Icon(Iconsax.user),
                      ),
                      title: Text(
                        'Abhidha Dixit',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      subtitle: Text(
                        'Lead Design and Doccumentation',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        'Links',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () async {
                      if (await launchUrlString(
                          'https://www.linkedin.com/in/sannidhyadubey')) {
                        await launchUrlString(
                          'https://www.linkedin.com/in/sannidhyadubey',
                        );
                      } else {
                        throw 'Could not launch';
                      }
                    },
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xffd1ffeb),
                        foregroundColor: Color(0xff006a53),
                        child: Icon(LineIcons.linkedin),
                      ),
                      title: Text(
                        'LinkedIn Profile',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      subtitle: Text(
                        'Latest news about the dev',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () async {
                      if (await launchUrlString(
                          'https://github.com/TheGuyDangerous/Voicerra')) {
                        await launchUrlString(
                          'https://github.com/TheGuyDangerous/Voicerra',
                        );
                      } else {
                        throw 'Could not launch';
                      }
                    },
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xffd1ffeb),
                        foregroundColor: Color(0xff006a53),
                        child: Icon(LineIcons.github),
                      ),
                      title: Text(
                        'Github',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      subtitle: Text(
                        'Check out our source code',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () async {
                      if (await launchUrlString(
                          'https://github.com/TheGuyDangerous/Voicerra/issues/new')) {
                        await launchUrlString(
                          'https://github.com/TheGuyDangerous/Voicerra/issues/new',
                        );
                      } else {
                        throw 'Could not launch';
                      }
                    },
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xffd1ffeb),
                        foregroundColor: Color(0xff006a53),
                        child: Icon(LineIcons.bug),
                      ),
                      title: Text(
                        'Report Bug',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      subtitle: Text(
                        'Found a bug? Report here.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () async {
                      if (await launchUrlString(
                          'https://paypal.me/GuyDangerous')) {
                        await launchUrlString(
                          'https://paypal.me/GuyDangerous',
                        );
                      } else {
                        throw 'Could not launch';
                      }
                    },
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xffd1ffeb),
                        foregroundColor: Color(0xff006a53),
                        child: Icon(LineIcons.donate),
                      ),
                      title: Text(
                        'Donate us!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      subtitle: Text(
                        'using PayPal',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _version() {
    print('hihi');
  }
}
