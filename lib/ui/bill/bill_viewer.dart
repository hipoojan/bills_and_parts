import 'package:bills_and_parts/ui/bill/bill_maker.dart';
import 'package:bills_and_parts/utils/models.dart';
import 'package:bills_and_parts/utils/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';

class BillViewer extends ConsumerWidget {
  final PageController controller;
  const BillViewer({this.controller});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final billsProvider = watch(billsNotifier);
    Bill _bill = billsProvider.bills[billsProvider.viewingIndex];
    return RawKeyboardListener(
        focusNode: FocusNode(onKey: (node, event) {
          if (event.isKeyPressed(LogicalKeyboardKey.escape)) WidgetsBinding.instance.addPostFrameCallback((_) => controller.jumpToPage(3));
          return false;
        }),
        child: Scaffold(
            body: Scrollbar(
          radius: Radius.circular(30),
          showTrackOnHover: true,
          isAlwaysShown: true,
          child: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                text: TextSpan(children: [
                                  TextSpan(text: 'CLIENT: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
                                  TextSpan(text: _bill.clientName, style: GoogleFonts.inter(color: Colors.black, fontSize: 20))
                                ])),
                            Container(height: 10),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(text: 'INVOICE NO: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
                              TextSpan(text: "${_bill.invoiceNo}" + '\t', style: GoogleFonts.inter(color: Colors.black, fontSize: 20)),
                              TextSpan(text: 'CODE: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
                              TextSpan(text: '${_bill.clientCode}', style: GoogleFonts.inter(color: Colors.black, fontSize: 20))
                            ])),
                            Container(height: 10),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(text: 'INVOICE DATE: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
                              TextSpan(text: DateFormat("dd MMM, yyyy").format(DateTime.parse(_bill.invoiceDate)), style: GoogleFonts.inter(color: Colors.black, fontSize: 20))
                            ])),
                            Container(height: 10),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(text: 'TOTAL ITEMS: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
                              TextSpan(text: "${billsProvider.totalItems(_bill.parts)}" + '\t', style: GoogleFonts.inter(color: Colors.black, fontSize: 20)),
                              TextSpan(text: 'GRAND TOTAL: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
                              TextSpan(text: '₹${_bill.amountGrand.toStringAsFixed(2)}', style: GoogleFonts.inter(color: Colors.black, fontSize: 20)),
                            ])),
                            Container(height: 10),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(text: 'PAYMENT: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
                              TextSpan(text: _bill.isPaid ? 'PAID' : 'PENDING', style: GoogleFonts.inter(color: _bill.isPaid ? Colors.green : Colors.red, fontSize: 20)),
                            ]))
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FaIcon(FontAwesomeIcons.clock, color: Colors.black, size: 16),
                                      Container(width: 10),
                                      Text(DateFormat("dd MMM, yyyy").format(DateTime.parse(_bill.billDate)), style: GoogleFonts.inter(color: Colors.black, fontSize: 16)),
                                    ],
                                  ),
                                ),
                                Container(width: 20),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: TextButton(
                                      onPressed: () => controller.jumpToPage(1),
                                      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(10)), backgroundColor: MaterialStateProperty.all(Colors.transparent)),
                                      child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: FaIcon(FontAwesomeIcons.times, color: Colors.black54, size: 25),
                                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black54, width: 2)))),
                                )
                              ],
                            ),
                            Container(height: 50),
                            Wrap(
                              spacing: 10,
                              children: [
                                TextButton(
                                    onPressed: () => billsProvider.savePdf(_bill).whenComplete(() async => Toast.show(
                                        "Saved to ${await getApplicationDocumentsDirectory().then((value) => value.path)}", context,
                                        backgroundColor: Colors.green, backgroundRadius: 10, duration: Toast.LENGTH_LONG)),
                                    style: ButtonStyle(
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 20, horizontal: 30)),
                                        backgroundColor: MaterialStateProperty.all(Colors.black12)),
                                    child: Text('Save', style: GoogleFonts.inter(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500))),
                                TextButton(
                                    onPressed: () => billsProvider.printPdf(_bill),
                                    style: ButtonStyle(
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.blueAccent, width: 2))),
                                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 20, horizontal: 30)),
                                        backgroundColor: MaterialStateProperty.all(Colors.transparent)),
                                    child: Text('Print', style: GoogleFonts.inter(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.w500))),
                                TextButton(
                                    onPressed: () => showBillMakerSheet(context, billsProvider, true, _bill),
                                    style: ButtonStyle(
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 20, horizontal: 30)),
                                        backgroundColor: MaterialStateProperty.all(Colors.blueAccent)),
                                    child: Text('Edit Bill', style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)))
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    Container(height: 40),
                    DataTable(
                      showBottomBorder: true,
                      dataTextStyle: GoogleFonts.inter(fontSize: 16, color: Colors.black),
                      headingTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                      showCheckboxColumn: true,
                      columns: [
                        DataColumn(label: Expanded(child: Text('SR\nNO.')), numeric: true),
                        DataColumn(label: Expanded(child: Text('Item Name'))),
                        DataColumn(label: Expanded(child: Text('Quantity')), numeric: true),
                        DataColumn(label: Expanded(child: Text('Price (₹)', softWrap: true, textAlign: TextAlign.center, maxLines: 2)), numeric: true),
                        DataColumn(label: Expanded(child: Text('GST (%)', softWrap: true, textAlign: TextAlign.center, maxLines: 2)), numeric: true),
                        DataColumn(label: Expanded(child: Text('Taxable\nVal (₹)', softWrap: true, textAlign: TextAlign.center, maxLines: 2)), numeric: true),
                      ],
                      rows: List.generate(
                          _bill.parts.length,
                          (index) => DataRow(cells: [
                                DataCell(Text('${index + 1}', textAlign: TextAlign.center)),
                                DataCell(Text('${_bill.parts[index].part.name}')),
                                DataCell(Text('${_bill.parts[index].quantity}', textAlign: TextAlign.center)),
                                DataCell(Text('${_bill.parts[index].part.price}', textAlign: TextAlign.left)),
                                DataCell(Text('${_bill.parts[index].part.tax}', textAlign: TextAlign.center)),
                                DataCell(Text('${_bill.parts[index].part.price * _bill.parts[index].quantity}', textAlign: TextAlign.center)),
                              ])),
                    ),
                    Container(height: 10),
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: RichText(
                                text: TextSpan(children: [
                              TextSpan(text: 'TOTAL INVOICE VALUE IN WORDS:\n\n', style: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
                              TextSpan(text: '${NumberToWord().convert("en-in", _bill.amountGrand.toInt())}.'.capitalizeFirstOfEach, style: GoogleFonts.inter(color: Colors.black, fontSize: 20))
                            ])),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: RichText(
                                    text: TextSpan(children: [
                                  TextSpan(text: 'AMOUNT BEFORE GST:  ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
                                  TextSpan(text: '₹${_bill.amountBfTax}', style: GoogleFonts.inter(color: Colors.black, fontSize: 20))
                                ])),
                              ),
                              returnTaxes(_bill, billsProvider),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: RichText(
                                    text: TextSpan(children: [
                                  TextSpan(text: 'GRAND TOTAL:  ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
                                  TextSpan(text: '₹${_bill.amountGrand.toStringAsFixed(2)}', style: GoogleFonts.inter(color: Colors.black, fontSize: 20))
                                ])),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                )),
          ),
        )));
  }

  Widget returnTaxes(Bill bill, BillsChangeNotifier billsProvider) {
    List<int> taxes = [];
    bill.parts.forEach((e) {
      if (!taxes.contains(e.part.tax)) taxes.add(e.part.tax);
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(taxes.length, (index) {
        List<PartWithQuantity> _parts = [];
        _parts.addAll(bill.parts.where((e) => e.part.tax == taxes[index]));
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: RichText(
              text: TextSpan(children: [
            TextSpan(text: '${bill.taxType} @  ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
            TextSpan(text: '${taxes[index]}% : ₹${billsProvider.calculateTax(_parts).toStringAsFixed(2)}', style: GoogleFonts.inter(color: Colors.black, fontSize: 20))
          ])),
        );
      }),
    );
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

extension CapExtension on String {
  String get inCaps => this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  String get capitalizeFirstOfEach => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
}
