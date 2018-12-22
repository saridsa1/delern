import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';

import '../../flutter/localization.dart';
import '../../flutter/styles.dart';
import '../../remote/analytics.dart';
import '../../remote/auth.dart';
import '../../views/helpers/launch_email.dart';
import '../../views/support_dev/support_development.dart';
import '../helpers/save_updates_dialog.dart';
import '../helpers/send_invite.dart';
import '../helpers/sign_in_widget.dart';

class NavigationDrawer extends StatefulWidget {
  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  String versionCode;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) => setState(() {
          versionCode = packageInfo.version;
        }));
  }

  @override
  Widget build(BuildContext context) {
    var user = CurrentUserWidget.of(context).user;

    var accountName =
        user.displayName ?? AppLocalizations.of(context).anonymous;

    return Drawer(
        child: ListView(
      // Remove any padding from the ListView.
      // https://flutter.io/docs/cookbook/design/drawer
      padding: EdgeInsets.zero,
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(accountName),
          accountEmail: Text(user.humanFriendlyIdentifier),
          currentAccountPicture: CircleAvatar(
            backgroundImage: user.photoUrl == null
                ? const AssetImage('images/anonymous.jpg')
                : NetworkImage(user.photoUrl),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.perm_identity),
          title: Text(user.isAnonymous
              ? AppLocalizations.of(context).navigationDrawerSignIn
              : AppLocalizations.of(context).navigationDrawerSignOut),
          onTap: () async {
            if (user.isAnonymous) {
              _promoteAnonymous(context);
            } else {
              Auth.instance.signOut();
              Navigator.pop(context);
            }
          },
        ),
        const Divider(height: 1.0),
        ListTile(
          title: Text(
            AppLocalizations.of(context).navigationDrawerCommunicateGroup,
            style: AppStyles.navigationDrawerGroupText,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.contact_mail),
          title:
              Text(AppLocalizations.of(context).navigationDrawerInviteFriends),
          onTap: () {
            sendInvite(context);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.live_help),
          title: Text(AppLocalizations.of(context).navigationDrawerContactUs),
          onTap: () async {
            Navigator.pop(context);
            await launchEmail(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.developer_board),
          title: Text(
              AppLocalizations.of(context).navigationDrawerSupportDevelopment),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    settings: const RouteSettings(name: '/support'),
                    builder: (context) => SupportDevelopment()));
          },
        ),
        const Divider(
          height: 1.0,
        ),
        AboutListTile(
          icon: const Icon(Icons.perm_device_information),
          child: Text(AppLocalizations.of(context).navigationDrawerAbout),
          applicationIcon: Image.asset('images/ic_launcher.png'),
          applicationVersion: versionCode,
          applicationLegalese: 'GNU General Public License v3.0',
        ),
      ],
    ));
  }

  Future<void> _promoteAnonymous(BuildContext context) async {
    logPromoteAnonymous();
    try {
      await Auth.instance.signIn(SignInProvider.google);
    } on PlatformException catch (_) {
      // TODO(ksheremet): Merge data
      logPromoteAnonymousFail();
      var signIn = await showSaveUpdatesDialog(
          context: context,
          changesQuestion: AppLocalizations.of(context).accountExistUserWarning,
          yesAnswer: AppLocalizations.of(context).navigationDrawerSignIn,
          noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
      if (signIn) {
        // Sign out of Firebase but retain the account that has been picked by
        // user.
        await Auth.instance.signOut();
        Auth.instance.signIn(SignInProvider.google, forceAccountPicker: false);
      } else {
        Navigator.of(context).pop();
      }
    }
  }
}
