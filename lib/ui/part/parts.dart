import 'dart:ui';
import 'package:bills_and_parts/ui/bill/bill_maker.dart';
import 'package:bills_and_parts/utils/models.dart';
import 'package:bills_and_parts/utils/providers.dart';
import 'package:bills_and_parts/ui/part/new_part.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
// import 'package:sizer/sizer.dart';

class Parts extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final partsProvider = watch(partsNotifier);
    if (partsProvider.parts.isEmpty) partsProvider.getParts();
    List<Part> _parts = partsProvider.isSearching ? partsProvider.searchedParts : partsProvider.parts;
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _parts.any((e) => e.isSelected)
              ? ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: TextButton(
                      onPressed: () {
                        List<Part> _parts = [];
                        _parts.addAll(partsProvider.parts.where((e) => e.isSelected));
                        showBillMakerSheet(context, context.read(billsNotifier), false, null, _parts);
                      },
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 20, horizontal: 40)),
                          backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                          elevation: MaterialStateProperty.all(15)),
                      child: Text('Create Bill', style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500))),
                )
              : Container(),
          Container(width: 20),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: TextButton(
                onPressed: () => showNewPartSheet(context, partsProvider, false, null),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 20, horizontal: 40)),
                    backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                    elevation: MaterialStateProperty.all(15)),
                child: Text('Add Part', style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500))),
          ),
        ],
      ),
      body: _parts.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FaIcon(Icons.warning_amber_rounded, color: Colors.black, size: 50),
                Container(height: 10),
                Text('No Parts Found!', style: GoogleFonts.inter(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w500)),
              ],
            )
          : Scrollbar(
              radius: Radius.circular(30),
              showTrackOnHover: true,
              isAlwaysShown: true,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Consumer(builder: (context, watch, child) {
                  final sortProvider = watch(sortNotifier(_parts));
                  return Padding(
                    padding: EdgeInsets.only(bottom: 85),
                    child: DataTable(
                      showBottomBorder: true,
                      headingTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                      dataTextStyle: GoogleFonts.inter(fontSize: 16, color: Colors.black),
                      sortAscending: sortProvider.isAscending,
                      sortColumnIndex: sortProvider.index,
                      showCheckboxColumn: true,
                      onSelectAll: (val) {
                        _parts.forEach((e) => e.isSelected = val);
                        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                        partsProvider.notifyListeners();
                      },
                      columns: [
                        DataColumn(label: Text('ID'), numeric: true, onSort: (columnIndex, ascending) => partsProvider.sortParts(sortProvider.setSort(columnIndex, ascending))),
                        DataColumn(label: Text('Name'), onSort: (columnIndex, ascending) => partsProvider.sortParts(sortProvider.setSort(columnIndex, ascending))),
                        DataColumn(label: Text('Price (₹)'), numeric: true, onSort: (columnIndex, ascending) => partsProvider.sortParts(sortProvider.setSort(columnIndex, ascending))),
                        DataColumn(label: Text('Tax (%)'), numeric: true, onSort: (columnIndex, ascending) => partsProvider.sortParts(sortProvider.setSort(columnIndex, ascending)))
                      ],
                      rows: List.generate(
                          _parts.length,
                          (index) => DataRow(onSelectChanged: _parts.any((e) => e.isSelected) ? (val) => partsProvider.toggleSelect(index) : null, selected: _parts[index].isSelected, cells: [
                                DataCell(Text('${_parts[index].id}'), onTap: () => showExtraOptions(context, partsProvider.parts[index].id, partsProvider)),
                                DataCell(Text(_parts[index].name), onTap: () => partsProvider.toggleSelect(index)),
                                DataCell(
                                    _parts[index].isEditingPrice
                                        ? RawKeyboardListener(
                                            focusNode: FocusNode(onKey: (node, event) {
                                              if (event.isKeyPressed(LogicalKeyboardKey.escape) || event.isKeyPressed(LogicalKeyboardKey.enter)) partsProvider.toggleEditingPrice(index);
                                              return false;
                                            }),
                                            onKey: (event) {
                                              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                                                partsProvider.editPart(
                                                    _parts[index].id,
                                                    _parts[index] =
                                                        Part(id: _parts[index].id, name: _parts[index].name, price: _parts[index].cachePrice, tax: _parts[index].tax, isEditingPrice: false));
                                                Toast.show("Part Successfully Edited!", context, backgroundColor: Colors.green, backgroundRadius: 10, duration: Toast.LENGTH_LONG);
                                              }
                                            },
                                            child: TextFormField(
                                                cursorColor: Colors.black,
                                                textAlign: TextAlign.center,
                                                autofocus: true,
                                                controller: TextEditingController(text: '${_parts[index].price}'),
                                                onChanged: (text) => _parts[index].cachePrice = text != "" ? int.parse(text) : 0,
                                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                                decoration: InputDecoration.collapsed(hintText: '₹', hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
                                                style: GoogleFonts.inter(fontSize: 16, color: Colors.black)),
                                          )
                                        : Text('${_parts[index].price}', textAlign: TextAlign.center),
                                    showEditIcon: true,
                                    onTap: () => partsProvider.toggleEditingPrice(index)),
                                DataCell(
                                    _parts[index].isEditingTax
                                        ? RawKeyboardListener(
                                            focusNode: FocusNode(onKey: (node, event) {
                                              if (event.isKeyPressed(LogicalKeyboardKey.escape) || event.isKeyPressed(LogicalKeyboardKey.enter)) partsProvider.toggleEditingTax(index);
                                              return false;
                                            }),
                                            onKey: (event) {
                                              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                                                partsProvider.editPart(
                                                    _parts[index].id,
                                                    _parts[index] =
                                                        Part(id: _parts[index].id, name: _parts[index].name, price: _parts[index].price, tax: _parts[index].cacheTax, isEditingPrice: false));
                                                Toast.show("Part Successfully Edited!", context, backgroundColor: Colors.green, backgroundRadius: 10, duration: Toast.LENGTH_LONG);
                                              }
                                            },
                                            child: TextFormField(
                                                cursorColor: Colors.black,
                                                textAlign: TextAlign.center,
                                                autofocus: true,
                                                controller: TextEditingController(text: '${_parts[index].tax}'),
                                                onChanged: (text) => _parts[index].cacheTax = text != "" ? int.parse(text) : 0,
                                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                                decoration: InputDecoration.collapsed(hintText: '%', hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 16)),
                                                style: GoogleFonts.inter(fontSize: 16, color: Colors.black)),
                                          )
                                        : Text('${_parts[index].tax}', textAlign: TextAlign.center),
                                    showEditIcon: true,
                                    onTap: () => partsProvider.toggleEditingTax(index))
                              ])),
                    ),
                  );
                }),
              ),
            ),
    );
  }

  showExtraOptions(BuildContext context, int id, PartsChangeNotifier partsProvider) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black38,
        enableDrag: true,
        builder: (context) {
          return Container(
              margin: EdgeInsets.symmetric(horizontal: 200),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
              child: Wrap(children: [
                TextButton(
                    onPressed: () => showNewPartSheet(context, partsProvider, true, partsProvider.parts.firstWhere((e) => e.id == id)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Edit Part', style: GoogleFonts.inter(fontSize: 22, color: Colors.black, fontWeight: FontWeight.w500)),
                      FaIcon(FontAwesomeIcons.edit, color: Colors.black, size: 22)
                    ]),
                    style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 30, vertical: 30)))),
                TextButton(
                    onPressed: () {
                      if (partsProvider.parts.where((e) => e.isSelected).isNotEmpty) {
                        partsProvider.parts.where((e) => e.isSelected).forEach((e) => partsProvider.deletePart(e.id));
                        Toast.show("Deleted All Selected Parts!", context, backgroundColor: Colors.green, backgroundRadius: 10, duration: Toast.LENGTH_LONG);
                        Navigator.pop(context);
                      } else {
                        partsProvider.deletePart(id).whenComplete(() {
                          Toast.show("#$id Part deleted.", context, backgroundColor: Colors.green, backgroundRadius: 10, duration: Toast.LENGTH_LONG);
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Delete', style: GoogleFonts.inter(fontSize: 22, color: Colors.red, fontWeight: FontWeight.w500)),
                      FaIcon(FontAwesomeIcons.trashAlt, color: Colors.red, size: 22)
                    ]),
                    style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 30, vertical: 30))))
              ]));
        });
  }

  showNewPartSheet(BuildContext context, PartsChangeNotifier partsProvider, bool isEditing, Part part) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black38,
        enableDrag: true,
        builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.4, maxChildSize: 0.6, minChildSize: 0.4, builder: (context, scrollController) => NewPart(partsProvider: partsProvider, isEditing: isEditing, part: part)));
  }

  showBillMakerSheet(BuildContext context, BillsChangeNotifier billProvider, bool isEditing, Bill bill, List<Part> parts) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black38,
        builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.95, maxChildSize: 1, minChildSize: 0.6, builder: (context, controller) => BillMaker(billsProvider: billProvider, isEditing: isEditing, bill: bill, parts: parts)));
  }
}
