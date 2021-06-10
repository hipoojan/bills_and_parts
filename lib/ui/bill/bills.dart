import 'package:bills_and_parts/ui/bill/bill_maker.dart';
import 'package:bills_and_parts/utils/models.dart';
import 'package:bills_and_parts/utils/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class Bills extends ConsumerWidget {
  final PageController controller;

  const Bills({this.controller});
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final billsProvider = watch(billsNotifier);
    if (billsProvider.bills.isEmpty) billsProvider.getBills();
    List<Bill> _bills = billsProvider.isSearching ? billsProvider.searchedBills : billsProvider.bills;
    return Scaffold(
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: TextButton(
            onPressed: () => showBillMakerSheet(context, billsProvider, false, null),
            style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 20, horizontal: 40)),
                backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                elevation: MaterialStateProperty.all(15)),
            child: Text('New Bill', style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500))),
      ),
      body: _bills.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FaIcon(Icons.warning_amber_rounded, color: Colors.black, size: 50),
                Container(height: 10),
                Text('No Bills Found!', style: GoogleFonts.inter(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w500)),
              ],
            )
          : Scrollbar(
              radius: Radius.circular(30),
              showTrackOnHover: true,
              isAlwaysShown: true,
              child: Padding(
                padding: EdgeInsets.only(bottom: 85),
                child: ListView(physics: BouncingScrollPhysics(), shrinkWrap: true, children: List.generate(_bills.length, (index) => returnBillLayout(context, index, _bills, billsProvider))),
              )),
    );
  }

  Widget returnBillLayout(BuildContext context, int index, List<Bill> _bills, BillsChangeNotifier billsProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 400, maxWidth: 800),
          child: Container(
            margin: EdgeInsets.only(top: index == 0 ? 40 : 20, bottom: index == 9 ? 40 : 0, left: 40, right: 20),
            child: TextButton(
                onPressed: () {
                  billsProvider.setViewingIndex(index);
                  WidgetsBinding.instance.addPostFrameCallback((_) => controller.jumpToPage(3));
                },
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)]),
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                text: TextSpan(children: [
                                  TextSpan(text: 'CLIENT: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 14)),
                                  TextSpan(text: _bills[index].clientName, style: GoogleFonts.inter(color: Colors.black, fontSize: 18))
                                ])),
                          ),
                          Row(
                            children: [
                              FaIcon(FontAwesomeIcons.clock, color: Colors.black, size: 16),
                              Container(width: 10),
                              Text(DateFormat("dd MMM, yyyy").format(DateTime.parse(_bills[index].billDate)), style: GoogleFonts.inter(color: Colors.black, fontSize: 16))
                            ],
                          )
                        ],
                      ),
                      Container(height: 5),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(text: 'INVOICE NO: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 14)),
                        TextSpan(text: "${_bills[index].invoiceNo}" + '\t', style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                        TextSpan(text: 'CODE: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 14)),
                        TextSpan(text: '${_bills[index].clientCode}', style: GoogleFonts.inter(color: Colors.black, fontSize: 18))
                      ])),
                      Container(height: 5),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(text: 'INVOICE DATE: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 14)),
                        TextSpan(text: DateFormat("dd MMM, yyyy").format(DateTime.parse(_bills[index].invoiceDate)), style: GoogleFonts.inter(color: Colors.black, fontSize: 18))
                      ])),
                      Container(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(text: 'TOTAL ITEMS: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 14)),
                            TextSpan(text: "${billsProvider.totalItems(_bills[index].parts)}" + '\t', style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                            TextSpan(text: 'GRAND TOTAL: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 14)),
                            TextSpan(text: '₹${_bills[index].amountGrand.toStringAsFixed(2)} ', style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                            TextSpan(
                                text: _bills[index].isPaid ? 'PAID' : 'PENDING',
                                style: GoogleFonts.inter(color: _bills[index].isPaid ? Colors.green : Colors.red, fontSize: 18, fontWeight: FontWeight.w500)),
                          ])),
                          TextButton.icon(
                              onPressed: () => showExtraOptions(context, _bills[index], billsProvider),
                              style: ButtonStyle(alignment: Alignment.bottomRight, minimumSize: MaterialStateProperty.all(Size(double.minPositive, double.minPositive))),
                              icon: FaIcon(FontAwesomeIcons.bars, color: Colors.black, size: 16),
                              label: Container())
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ],
    );
  }

  showExtraOptions(BuildContext context, Bill bill, BillsChangeNotifier billsProvider) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black38,
        enableDrag: true,
        builder: (context) {
          return Container(
              margin: EdgeInsets.symmetric(horizontal: 50.0.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
              child: Wrap(children: [
                !bill.isPaid
                    ? TextButton(
                        onPressed: () {
                          billsProvider.makePaid(bill);
                          Toast.show("Payment Successful!", context, backgroundRadius: 10, backgroundColor: Colors.green, duration: Toast.LENGTH_LONG);
                          Navigator.pop(context);
                        },
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Make Paid', style: GoogleFonts.inter(fontSize: 22, color: Colors.green, fontWeight: FontWeight.w500)),
                          FaIcon(FontAwesomeIcons.moneyBillWave, color: Colors.green, size: 22)
                        ]),
                        style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 30, vertical: 30))))
                    : Container(),
                TextButton(
                    onPressed: () => billsProvider.savePdf(bill).whenComplete(() async => Toast.show("Saved to ${await getApplicationDocumentsDirectory().then((value) => value.path)}", context,
                        backgroundColor: Colors.green, backgroundRadius: 10, duration: Toast.LENGTH_LONG)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Save', style: GoogleFonts.inter(fontSize: 22, color: Colors.black, fontWeight: FontWeight.w500)),
                      FaIcon(FontAwesomeIcons.save, color: Colors.black, size: 22)
                    ]),
                    style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 30, vertical: 30)))),
                TextButton(
                    onPressed: () => billsProvider.printPdf(bill),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Print', style: GoogleFonts.inter(fontSize: 22, color: Colors.black, fontWeight: FontWeight.w500)),
                      FaIcon(FontAwesomeIcons.print, color: Colors.black, size: 22)
                    ]),
                    style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 30, vertical: 30)))),
                TextButton(
                    onPressed: () => showBillMakerSheet(context, billsProvider, true, bill),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Edit Bill', style: GoogleFonts.inter(fontSize: 22, color: Colors.black, fontWeight: FontWeight.w500)),
                      FaIcon(FontAwesomeIcons.edit, color: Colors.black, size: 22)
                    ]),
                    style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 30, vertical: 30)))),
                TextButton(
                    onPressed: () => billsProvider.deleteBill(bill).whenComplete(() {
                          Toast.show("Successfully Deleted Bill!", context, backgroundColor: Colors.green, backgroundRadius: 10, duration: Toast.LENGTH_LONG);
                          Navigator.pop(context);
                        }),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Delete', style: GoogleFonts.inter(fontSize: 22, color: Colors.red, fontWeight: FontWeight.w500)),
                      FaIcon(FontAwesomeIcons.trashAlt, color: Colors.red, size: 22)
                    ]),
                    style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 30, vertical: 30))))
              ]));
        });
  }

  showBillMakerSheet(BuildContext context, BillsChangeNotifier billProvider, bool isEditing, Bill bill) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black38,
        builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.95, maxChildSize: 1, minChildSize: 0.95, builder: (context, controller) => BillMaker(billsProvider: billProvider, isEditing: isEditing, bill: bill)));
  }
}
