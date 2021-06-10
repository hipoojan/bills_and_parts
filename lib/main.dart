import 'package:bills_and_parts/ui/home.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

ThemeData _themeData = ThemeData(textTheme: TextTheme(button: GoogleFonts.inter(color: Colors.black)));

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MaterialApp(home: Main(),debugShowCheckedModeBanner: false,theme: _themeData)));
  doWhenWindowReady((){
    final win = appWindow;
    final initSize = Size(1100,700);
    win.minSize = initSize;
    win.size = initSize;
    win.alignment = Alignment.center;
    win.title = "SSA Bills & Parts";
    win.show();
  });
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) => OrientationBuilder(builder: (context, orientation) {
     SizerUtil.setScreenSize(constraints, orientation);
     return Home();
    }));
  }
}


