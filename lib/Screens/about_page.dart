import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      backgroundColor: const Color(0xFF2f2554),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF2f2554),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Voicerra',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Raleway', fontSize: 24.0),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(50),
              topLeft: Radius.circular(50),
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: ListView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'assets/images/icon.png',
                      height: 100,
                    ),
                  ),
                ],
              ),
              InkWell(
                borderRadius: BorderRadius.circular(15.0),
                onTap: () {},
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFf6edfd),
                    foregroundColor: Color(0xFF512DA8),
                    child: Icon(Iconsax.cpu),
                  ),
                  title: const Text('App Version'),
                  subtitle: Text(_packageInfo.version),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    'Contributors',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFf6edfd),
                    foregroundColor: Color(0xFF512DA8),
                    child: Icon(Iconsax.user),
                  ),
                  title: Text('Sannidhya Dubey'),
                  subtitle: Text('Lead Dev & App Design'),
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
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFf6edfd),
                    foregroundColor: Color(0xFF512DA8),
                    child: Icon(Iconsax.user),
                  ),
                  title: Text('Bishal Roy'),
                  subtitle: Text('Lead Designer'),
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
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFf6edfd),
                    foregroundColor: Color(0xFF512DA8),
                    child: Icon(Iconsax.user),
                  ),
                  title: Text('Sneha Soni'),
                  subtitle: Text('Lead Design and Doccumentation'),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(15.0),
                onTap: null,
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFf6edfd),
                    foregroundColor: Color(0xFF512DA8),
                    child: Icon(Iconsax.user),
                  ),
                  title: Text('Abhidha Dixit'),
                  subtitle: Text('Lead Design and Doccumentation'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    'Links',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFf6edfd),
                    foregroundColor: Color(0xFF512DA8),
                    child: Icon(LineIcons.linkedin),
                  ),
                  title: Text('LinkedIn Profile'),
                  subtitle: Text('Latest news about the dev'),
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
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFf6edfd),
                    foregroundColor: Color(0xFF512DA8),
                    child: Icon(LineIcons.github),
                  ),
                  title: Text('Github'),
                  subtitle: Text('Check out our source code'),
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
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFf6edfd),
                    foregroundColor: Color(0xFF512DA8),
                    child: Icon(LineIcons.bug),
                  ),
                  title: Text('Report Bug'),
                  subtitle: Text('Found a bug? Report here.'),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(15.0),
                onTap: () async {
                  if (await launchUrlString('https://paypal.me/GuyDangerous')) {
                    await launchUrlString(
                      'https://paypal.me/GuyDangerous',
                    );
                  } else {
                    throw 'Could not launch';
                  }
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFf6edfd),
                    foregroundColor: Color(0xFF512DA8),
                    child: Icon(LineIcons.donate),
                  ),
                  title: Text('Donate us!'),
                  subtitle: Text('using PayPal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
