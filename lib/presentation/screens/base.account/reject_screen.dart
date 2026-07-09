import 'package:flutter/material.dart';
import 'package:talent_hr/app/locale_controller.dart';

class RejectScreen extends StatefulWidget {
  const RejectScreen({super.key});

  @override
  _RejectScreenState createState() => _RejectScreenState();
}

class _RejectScreenState extends State<RejectScreen> {
  @override
  Widget build(BuildContext context) {
    //SizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Image(
                width: 250,
                height: 250,
                color: Colors.red,
                image: AssetImage('assets/logos/ic_device.png'),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              context.l10n.accessDenied,
              style: TextStyle(
                color: Colors.red,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              context.l10n.youDontHaveAccess,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              context.l10n.pleaseContact,
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
