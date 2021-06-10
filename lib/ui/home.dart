import 'package:bills_and_parts/ui/bill/bill_viewer.dart';
import 'package:bills_and_parts/ui/bill/bills.dart';
import 'package:bills_and_parts/ui/part/parts.dart';
import 'package:bills_and_parts/ui/settings.dart';
import 'package:bills_and_parts/utils/models.dart';
import 'package:bills_and_parts/utils/providers.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatelessWidget {
  final PageController _controller = PageController(initialPage: 0, keepPage: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: WindowBorder(color: Colors.transparent, child: Row(children: [_leftSide(), _rightSide()]), width: 1));
  }

  Widget _leftSide() => Container(width: 220, child: Container(color: Colors.white, child: Column(children: [WindowTitleBarBox(child: MoveWindow()), Expanded(child: _sidePanel())])));

  Widget _rightSide() {
    return Expanded(
        child: Column(children: [
      Container(
          alignment: Alignment.topCenter,
          color: Colors.white,
          child: WindowTitleBarBox(
              child: Row(children: [
            Expanded(child: MoveWindow()),
            Row(children: [MinimizeWindowButton(), MaximizeWindowButton(), CloseWindowButton()])
          ]))),
      Padding(
        padding: EdgeInsets.only(left: 35),
        child: Consumer(builder: (context, watch, child) {
          final tabProvider = watch(tabNotifier);
          final partsProvider = watch(partsNotifier);
          final billsProvider = watch(billsNotifier);
          return TextField(
              cursorColor: Colors.black,
              onChanged: (text) => tabProvider.activeTab == 0 ? partsProvider.searchPart(text) : billsProvider.searchBill(text),
              decoration: InputDecoration.collapsed(hintText: 'Search for ${tabProvider.activeTab == 0 ? "parts" : "bills"}...', hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 22)),
              style: GoogleFonts.inter(fontSize: 22, color: Colors.black));
        }),
      ),
      Container(height: 30),
      Expanded(
        child: Container(
          decoration:
              BoxDecoration(color: Color(0xffececec), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, spreadRadius: 2)], borderRadius: BorderRadius.only(topLeft: Radius.circular(50))),
          child: ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(50)),
            child: Consumer(builder: (context, watch, child) {
              final tabProvider = watch(tabNotifier);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_controller.hasClients) _controller.animateToPage(tabProvider.activeTab, duration: Duration(milliseconds: 250), curve: Curves.bounceInOut);
              });
              return PageView(
                  children: [Parts(), Bills(controller: _controller), Settings(settingsProvider: context.read(settingsNotifier)), BillViewer(controller: _controller)],
                  pageSnapping: true,
                  physics: NeverScrollableScrollPhysics(),
                  onPageChanged: (value) {},
                  controller: _controller);
            }),
          ),
        ),
      )
    ]));
  }

  Widget _sidePanel() {
    return Consumer(builder: (context, watch, child) {
      final tabProvider = watch(tabNotifier);
      return Column(
        children: [
          Expanded(flex: 2, child: Container(alignment: Alignment.topCenter, child: Image.asset("assets/logo.png", height: 80, width: 80))),
          Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                            onPressed: () => tabProvider.setTab(0),
                            style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.only(left: 50, top: 25, bottom: 25)), overlayColor: MaterialStateProperty.all(Color(0x33ececec))),
                            child: Row(children: [
                              FaIcon(FontAwesomeIcons.wrench, color: Colors.black, size: 22),
                              Container(width: 20),
                              Text('Parts', style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.w500))
                            ])),
                        TextButton(
                            onPressed: () => tabProvider.setTab(1),
                            style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.only(left: 50, top: 25, bottom: 25)), overlayColor: MaterialStateProperty.all(Color(0x33ececec))),
                            child: Row(children: [
                              FaIcon(FontAwesomeIcons.fileInvoice, color: Colors.black, size: 22),
                              Container(width: 25),
                              Text('Bills', style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.w500))
                            ])),
                        TextButton(
                            onPressed: () => tabProvider.setTab(2),
                            style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.only(left: 50, top: 25, bottom: 25)), overlayColor: MaterialStateProperty.all(Color(0x33ececec))),
                            child: Row(children: [
                              FaIcon(FontAwesomeIcons.cog, color: Colors.black, size: 22),
                              Container(width: 20),
                              Text('Settings', style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.w500))
                            ]))
                      ],
                    ),
                  ),
                  Align(
                      alignment: Alignment.topRight,
                      child: AnimatedContainer(
                          height: 55,
                          width: 10,
                          transform: Matrix4.translationValues(0, (tabProvider.activeTab * 62 + 5).toDouble(), 0),
                          decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.horizontal(left: Radius.circular(20))),
                          duration: Duration(milliseconds: 250)))
                ],
              )),
          Expanded(
              flex: 4,
              child: tabProvider.activeTab == 0
                  ? Consumer(builder: (context, watch, child) {
                      final partsProvider = watch(partsNotifier);
                      return Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 30),
                              child: RichText(
                                  text: TextSpan(children: [
                                TextSpan(text: 'TOTAL PARTS:  ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                                TextSpan(text: '${partsProvider.parts.length}', style: GoogleFonts.inter(color: Colors.black, fontSize: 22))
                              ])),
                            )
                          ],
                        ),
                      );
                    })
                  : Consumer(builder: (context, watch, child) {
                      final billsProvider = watch(billsNotifier);
                      return Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 30),
                              child: RichText(
                                  text: TextSpan(children: [
                                TextSpan(text: 'TOTAL BILLS:  ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                                TextSpan(text: '${billsProvider.bills.length}', style: GoogleFonts.inter(color: Colors.black, fontSize: 22))
                              ])),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 30),
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    TextSpan(text: 'PAYMENT PENDING:  ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                                    TextSpan(
                                        text: '₹${calculatePendingPayment(billsProvider.bills).toStringAsFixed(2)}',
                                        style: GoogleFonts.inter(color: calculatePendingPayment(billsProvider.bills).toInt() == 0 ? Colors.green : Colors.red, fontSize: 22))
                                  ])),
                            )
                          ],
                        ),
                      );
                    })),
        ],
      );
    });
  }

  double calculatePendingPayment(List<Bill> bills) {
    double total = 0;
    bills.forEach((e) => total += !e.isPaid ? e.amountGrand : 0);
    return total;
  }
}
