import 'package:bills_and_parts/utils/models.dart';
import 'package:bills_and_parts/utils/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class BillMaker extends StatefulWidget {
  final BillsChangeNotifier billsProvider;
  final bool isEditing;
  final Bill bill;
  final List<Part> parts;
  const BillMaker({this.billsProvider, this.isEditing, this.bill, this.parts});

  @override
  _BillMakerState createState() => _BillMakerState();
}

class _BillMakerState extends State<BillMaker> {
  TextEditingController _clientNameController, _clientAddressController, _clientGSTINController, _clientStateController, _clientCodeController, _invoiceNoController, _searchController;
  DateTime _invoiceDate;
  List<PartWithQuantity> parts = [];
  ScrollController _scrollController;
  String taxValue = "";

  @override
  void initState() {
    super.initState();
    _clientNameController = TextEditingController(text: widget.isEditing ? widget.bill.clientName : "");
    _clientAddressController = TextEditingController(text: widget.isEditing ? widget.bill.clientAddress : "");
    _clientGSTINController = TextEditingController(text: widget.isEditing ? widget.bill.clientGSTIN : "");
    _clientStateController = TextEditingController(text: widget.isEditing ? widget.bill.clientState : "");
    _clientCodeController = TextEditingController(text: widget.isEditing ? widget.bill.clientCode.toString() : "");
    _invoiceNoController = TextEditingController(text: widget.isEditing ? widget.bill.invoiceNo.toString() : "");
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    if (widget.isEditing) _invoiceDate = DateTime.parse(widget.bill.invoiceDate);
    if (widget.isEditing) parts = widget.bill.parts;
    if (widget.parts != null) widget.parts.forEach((e) => parts.add(PartWithQuantity(part: e, quantity: 1)));
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientAddressController.dispose();
    _clientGSTINController.dispose();
    _clientStateController.dispose();
    _clientCodeController.dispose();
    _invoiceNoController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scrollbar(
          radius: Radius.circular(30),
          showTrackOnHover: true,
          isAlwaysShown: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0.w),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(25),
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                              child: TextField(
                                  cursorColor: Colors.black,
                                  controller: _clientNameController,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration.collapsed(hintText: "Name*", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                                  style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                            ),
                            Container(
                              padding: EdgeInsets.all(25),
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                              child: TextField(
                                  cursorColor: Colors.black,
                                  controller: _clientAddressController,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration.collapsed(hintText: "Address*", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                                  style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                            ),
                            Container(
                              padding: EdgeInsets.all(25),
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                              child: TextField(
                                  cursorColor: Colors.black,
                                  controller: _clientGSTINController,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration.collapsed(hintText: "GSTIN NO.", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                                  style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 7,
                                    child: Container(
                                      padding: EdgeInsets.all(25),
                                      margin: EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                                      child: TextField(
                                          cursorColor: Colors.black,
                                          controller: _clientStateController,
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration.collapsed(hintText: "State*", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                                          style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                                    )),
                                Container(width: 20),
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.all(25),
                                      margin: EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                                      child: TextField(
                                          cursorColor: Colors.black,
                                          controller: _clientCodeController,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                          decoration: InputDecoration.collapsed(hintText: "Code*", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                                          style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                                    ))
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(width: 20),
                      Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(25),
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                                child: TextField(
                                    cursorColor: Colors.black,
                                    controller: _invoiceNoController,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                    decoration: InputDecoration.collapsed(hintText: "Invoice Number*", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                                    style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                              ),
                              Container(
                                width: double.maxFinite,
                                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                                child: TextButton(
                                    onPressed: () => _selectDate(context),
                                    style: ButtonStyle(alignment: Alignment.centerLeft),
                                    child: Text(_invoiceDate != null ? DateFormat("dd MMM, yyyy").format(_invoiceDate) : "Invoice Date*",
                                        style: GoogleFonts.inter(color: _invoiceDate != null ? Colors.black : Colors.black54, fontSize: 18))),
                              ),
                              Container(
                                width: double.maxFinite,
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                                child: Wrap(
                                  children: [
                                    RadioListTile(
                                        value: "CGST",
                                        groupValue: taxValue,
                                        onChanged: (val) => setState(() => taxValue = val),
                                        activeColor: Colors.blueAccent,
                                        title: Text('CGST', style: GoogleFonts.inter(color: Colors.black, fontSize: 16))),
                                    RadioListTile(
                                        value: "SGST",
                                        groupValue: taxValue,
                                        onChanged: (val) => setState(() => taxValue = val),
                                        activeColor: Colors.blueAccent,
                                        tileColor: Colors.black,
                                        title: Text('SGST', style: GoogleFonts.inter(color: Colors.black, fontSize: 16))),
                                    RadioListTile(
                                        value: "IGST",
                                        groupValue: taxValue,
                                        onChanged: (val) => setState(() => taxValue = val),
                                        activeColor: Colors.blueAccent,
                                        tileColor: Colors.black,
                                        title: Text('IGST', style: GoogleFonts.inter(color: Colors.black, fontSize: 16))),
                                  ],
                                ),
                              )
                            ],
                          ))
                    ],
                  ),
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
                        parts.length,
                        (index) => DataRow(cells: [
                              DataCell(Text('${index + 1}', textAlign: TextAlign.center)),
                              DataCell(Text('${parts[index].part.name}')),
                              DataCell(Row(children: [
                                TextButton.icon(
                                    style: ButtonStyle(minimumSize: MaterialStateProperty.all(Size(20, 20)), alignment: Alignment.center),
                                    onPressed: () {
                                      setState(() => parts[index].quantity--);
                                      if (parts[index].quantity == 0) setState(() => parts.removeAt(index));
                                    },
                                    icon: FaIcon(FontAwesomeIcons.minusCircle, color: Colors.black54, size: 20),
                                    label: Container()),
                                Container(width: 5),
                                Text('${parts[index].quantity}', textAlign: TextAlign.center),
                                Container(width: 10),
                                TextButton.icon(
                                    style: ButtonStyle(minimumSize: MaterialStateProperty.all(Size(20, 20)), alignment: Alignment.center),
                                    onPressed: () => setState(() => parts[index].quantity++),
                                    icon: FaIcon(FontAwesomeIcons.plusCircle, color: Colors.black54, size: 20),
                                    label: Container())
                              ])),
                              DataCell(Text('${parts[index].part.price}', textAlign: TextAlign.center)),
                              DataCell(Text('${parts[index].part.tax}', textAlign: TextAlign.center)),
                              DataCell(Text('${parts[index].part.price * parts[index].quantity}', textAlign: TextAlign.center)),
                            ])),
                  ),
                  parts.isEmpty
                      ? Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Text('No Items Added!', style: GoogleFonts.inter(color: Colors.black, fontSize: 18)))
                      : Container(height: 30),
                  Consumer(builder: (context, watch, child) {
                    final partsProvider = watch(partsNotifier);
                    if (partsProvider.parts.isEmpty) partsProvider.getParts();
                    return Container(
                      height: 150,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 7,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                                child: RawKeyboardListener(
                                  focusNode: FocusNode(),
                                  onKey: (event) {
                                    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                                      if (_searchController.text.isNotEmpty) {
                                        if (partsProvider.parts.any((e) => e.id == int.parse(_searchController.text))) {
                                          if (!parts.any((e) => e.part.id == int.parse(_searchController.text))) {
                                            setState(() => parts.add(PartWithQuantity(part: partsProvider.parts.firstWhere((e) => e.id == int.parse(_searchController.text)), quantity: 1)));
                                            _searchController.clear();
                                            _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 250), curve: Curves.bounceInOut);
                                          } else
                                            Toast.show("Part already added!", context, backgroundRadius: 10, backgroundColor: Colors.red, duration: Toast.LENGTH_LONG);
                                        } else
                                          Toast.show("No Such Part Found!", context, backgroundRadius: 10, backgroundColor: Colors.red, duration: Toast.LENGTH_LONG);
                                      } else
                                        Toast.show("No Search Query Found!", context, backgroundRadius: 10, backgroundColor: Colors.red, duration: Toast.LENGTH_LONG);
                                    }
                                  },
                                  child: TextField(
                                      cursorColor: Colors.black,
                                      autofocus: true,
                                      controller: _searchController,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                      textInputAction: TextInputAction.done,
                                      decoration: InputDecoration.collapsed(hintText: "Enter Part's #ID", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                                      style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                                ),
                              )),
                          Container(width: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: TextButton(
                                onPressed: () {
                                  if (_searchController.text.isNotEmpty) {
                                    if (partsProvider.parts.any((e) => e.id == int.parse(_searchController.text))) {
                                      if (!parts.any((e) => e.part.id == int.parse(_searchController.text))) {
                                        setState(() => parts.add(PartWithQuantity(part: partsProvider.parts.firstWhere((e) => e.id == int.parse(_searchController.text)), quantity: 1)));
                                        _searchController.clear();
                                        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 250), curve: Curves.bounceInOut);
                                      } else
                                        Toast.show("Part already added!", context, backgroundRadius: 10, backgroundColor: Colors.red, duration: Toast.LENGTH_LONG);
                                    } else
                                      Toast.show("No Such Part Found!", context, backgroundRadius: 10, backgroundColor: Colors.red, duration: Toast.LENGTH_LONG);
                                  } else
                                    Toast.show("No Search Query Found!", context, backgroundRadius: 10, backgroundColor: Colors.red, duration: Toast.LENGTH_LONG);
                                },
                                style:
                                    ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 20, horizontal: 40)), backgroundColor: MaterialStateProperty.all(Colors.blueAccent)),
                                child: Text('Add Part', style: GoogleFonts.inter(color: Colors.white, fontSize: 18))),
                          )
                        ],
                      ),
                    );
                  })
                ],
              ),
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              width: double.maxFinite,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
              margin: EdgeInsets.symmetric(horizontal: 20.0.w),
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(text: 'TOTAL ITEMS: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 14)),
                    TextSpan(text: "${widget.billsProvider.totalItems(parts)}" + '\t', style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                    TextSpan(text: 'BEFORE TAX: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 14)),
                    TextSpan(text: "₹${widget.billsProvider.calculateBeforeTax(parts)}" + '\t', style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                    TextSpan(text: 'GRAND TOTAL: ', style: GoogleFonts.inter(color: Colors.black54, fontSize: 14)),
                    TextSpan(text: '₹${widget.billsProvider.calculateGrandTotal(parts).roundToDouble()} ', style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                  ])),
                  ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(80)),
                      child: TextButton(
                          onPressed: () {
                            if (_clientNameController.text.isNotEmpty &&
                                _clientAddressController.text.isNotEmpty &&
                                _clientStateController.text.isNotEmpty &&
                                _clientCodeController.text.isNotEmpty &&
                                _invoiceNoController.text.isNotEmpty &&
                                _invoiceDate != null &&
                                parts.isNotEmpty &&
                                taxValue != "") {
                              if (widget.isEditing) {
                                widget.billsProvider
                                    .editBill(
                                        DateTime.parse(widget.bill.billDate),
                                        Bill(
                                            parts: parts,
                                            isPaid: false,
                                            invoiceNo: int.parse(_invoiceNoController.text),
                                            clientName: _clientNameController.text,
                                            clientAddress: _clientAddressController.text,
                                            clientState: _clientStateController.text,
                                            clientCode: int.parse(_clientCodeController.text),
                                            invoiceDate: _invoiceDate.toString(),
                                            clientGSTIN: _clientGSTINController.text,
                                            billDate: widget.bill.billDate,
                                            amountGrand: widget.billsProvider.calculateGrandTotal(parts),
                                            taxType: taxValue,
                                            amountBfTax: widget.billsProvider.calculateBeforeTax(parts)))
                                    .whenComplete(() {
                                  Toast.show("Bill Successfully Edited!", context, backgroundRadius: 10, backgroundColor: Colors.green, duration: Toast.LENGTH_LONG);
                                  Navigator.pop(context);
                                });
                              } else {
                                widget.billsProvider
                                    .addBill(Bill(
                                        parts: parts,
                                        isPaid: false,
                                        invoiceNo: int.parse(_invoiceNoController.text),
                                        clientName: _clientNameController.text,
                                        clientAddress: _clientAddressController.text,
                                        clientState: _clientStateController.text,
                                        clientCode: int.parse(_clientCodeController.text),
                                        invoiceDate: _invoiceDate.toString(),
                                        clientGSTIN: _clientGSTINController.text,
                                        billDate: DateTime.now().toString(),
                                        amountGrand: widget.billsProvider.calculateGrandTotal(parts),
                                        amountBfTax: widget.billsProvider.calculateBeforeTax(parts)))
                                    .whenComplete(() {
                                  Toast.show("Bill Successfully Created!", context, backgroundRadius: 10, backgroundColor: Colors.green, duration: Toast.LENGTH_LONG);
                                  Navigator.pop(context);
                                });
                              }
                            } else
                              Toast.show("Provide all the required(*) fields!", context, backgroundRadius: 10, backgroundColor: Colors.red, duration: Toast.LENGTH_LONG);
                          },
                          style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(10)), backgroundColor: MaterialStateProperty.all(Colors.white)),
                          child: Container(
                              padding: EdgeInsets.all(10),
                              child: FaIcon(FontAwesomeIcons.check, color: Colors.green, size: 25),
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.green, width: 2)))))
                ],
              ),
            ))
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2015), lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != DateTime.now()) setState(() => _invoiceDate = pickedDate);
  }
}
