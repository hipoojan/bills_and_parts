import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'models.dart';
import 'package:intl/intl.dart';
import 'package:bills_and_parts/ui/bill/bill_viewer.dart';

final tabNotifier = ChangeNotifierProvider((ref) => TabChangeNotifier());
final sortNotifier = ChangeNotifierProvider.family((ref, parts) => SortChangeNotifier(parts));
final partsNotifier = ChangeNotifierProvider((ref) => PartsChangeNotifier());
final billsNotifier = ChangeNotifierProvider((ref) => BillsChangeNotifier());
final settingsNotifier = ChangeNotifierProvider((ref) => SettingsChangeNotifier());

class TabChangeNotifier extends ChangeNotifier {
  int _activeTab = 0;
  int get activeTab => _activeTab;

  setTab(int i) {
    _activeTab = i;
    notifyListeners();
  }
}

class SortChangeNotifier extends ChangeNotifier {
  final List<Part> parts;
  SortChangeNotifier(this.parts);

  int _index = 0;
  bool _ascending = true;
  int get index => _index;
  bool get isAscending => _ascending;

  List<Part> setSort(int index, bool isAscending) {
    _index = index;
    _ascending = isAscending;
    notifyListeners();
    switch (index) {
      case 0:
        parts.sort((a, b) => _ascending ? a.id.compareTo(b.id) : b.id.compareTo(a.id));
        break;
      case 1:
        parts.sort((a, b) => _ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
        break;
      case 2:
        parts.sort((a, b) => _ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
        break;
      case 3:
        parts.sort((a, b) => _ascending ? a.tax.compareTo(b.tax) : b.tax.compareTo(a.tax));
        break;
    }
    return parts;
  }
}

class PartsChangeNotifier extends ChangeNotifier {
  List<Part> _parts = [], _searchedParts = [];
  List<Part> get parts => _parts;
  List<Part> get searchedParts => _searchedParts;
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  editPart(int id, Part part) async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}\\parts.json');
    _parts.removeWhere((e) => e.id == id);
    _parts.add(part);
    String json = jsonEncode(_parts.map((e) => e.toJson()).toList()).toString();
    file.writeAsString(json).whenComplete(() => print("SAVED " + '${directory.path}\\parts.json'));
    parts.sort((a, b) => a.id.compareTo(b.id));
    notifyListeners();
  }

  Future addPart(Part part) async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}\\parts.json');
    _parts.add(part);
    String json = jsonEncode(_parts.map((e) => e.toJson()).toList()).toString();
    file.writeAsString(json).whenComplete(() => print("SAVED " + '${directory.path}\\parts.json'));
    parts.sort((a, b) => a.id.compareTo(b.id));
    notifyListeners();
  }

  Future deletePart(int id) async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}\\parts.json');
    _parts.removeWhere((e) => e.id == id);
    String json = jsonEncode(_parts.map((e) => e.toJson()).toList()).toString();
    file.writeAsString(json).whenComplete(() => print("SAVED " + '${directory.path}\\parts.json'));
    parts.sort((a, b) => a.id.compareTo(b.id));
    notifyListeners();
  }

  getParts() async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}\\parts.json');
    String json = await file.readAsString();
    _parts = (jsonDecode(json) as List).map((e) => Part.fromJson(e)).toList();
    parts.sort((a, b) => a.id.compareTo(b.id));
    notifyListeners();
  }

  sortParts(List<Part> p) {
    _parts = p;
    notifyListeners();
  }

  toggleSelect(int index) {
    _parts[index].isSelected = !_parts[index].isSelected;
    notifyListeners();
  }

  toggleEditingPrice(int index) {
    _parts[index].isEditingPrice = !_parts[index].isEditingPrice;
    notifyListeners();
  }

  toggleEditingTax(int index) {
    _parts[index].isEditingTax = !_parts[index].isEditingTax;
    notifyListeners();
  }

  searchPart(String text) {
    if (text.isNotEmpty) {
      _isSearching = true;
      _searchedParts = _parts.where((e) => e.toJson().values.toString().toLowerCase().contains(text.toLowerCase())).toList();
    } else
      _isSearching = false;
    notifyListeners();
  }
}

class BillsChangeNotifier extends ChangeNotifier {
  List<Bill> _bills = [], _searchedBills = [];
  int _viewingIndex;
  int get viewingIndex => _viewingIndex;
  bool _isSearching = false;
  List<Bill> get bills => _bills;
  List<Bill> get searchedBills => _searchedBills;
  bool get isSearching => _isSearching;

  getBills() async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}\\bills.json');
    String json = await file.readAsString();
    _bills = (jsonDecode(json) as List).map((e) => Bill.fromJson(e)).toList();
    notifyListeners();
  }

  Future addBill(Bill bill) async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}\\bills.json');
    _bills.add(bill);
    String json = jsonEncode(_bills.map((e) => e.toJson()).toList()).toString();
    file.writeAsString(json).whenComplete(() => print("SAVED " + '${directory.path}\\bills.json'));
    notifyListeners();
  }

  Future editBill(DateTime billDate, Bill bill) async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}\\bills.json');
    _bills.removeWhere((e) => DateTime.parse(e.billDate).isAtSameMomentAs(billDate));
    _bills.add(bill);
    String json = jsonEncode(_bills.map((e) => e.toJson()).toList()).toString();
    file.writeAsString(json).whenComplete(() => print("SAVED " + '${directory.path}\\bills.json'));
    notifyListeners();
  }

  Future deleteBill(Bill bill) async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}\\bills.json');
    _bills.remove(bill);
    String json = jsonEncode(_bills.map((e) => e.toJson()).toList()).toString();
    file.writeAsString(json).whenComplete(() => print("SAVED " + '${directory.path}\\bills.json'));
    notifyListeners();
  }

  makePaid(Bill bill) async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}\\bills.json');
    bill.isPaid = true;
    String json = jsonEncode(_bills.map((e) => e.toJson()).toList()).toString();
    file.writeAsString(json).whenComplete(() => print("SAVED " + '${directory.path}\\bills.json'));
    notifyListeners();
  }

  Future<PdfDocument> makePdf(Bill bill) async {
    SettingsChangeNotifier settingsChangeNotifier = SettingsChangeNotifier();
    CompanyInfo companyInfo = await settingsChangeNotifier.getData();
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();
    page.graphics.drawRectangle(bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height), pen: PdfPen(PdfColor(91, 155, 213, 255)));
    final PdfGrid grid = _getGrid(bill);
    final PdfLayoutResult result = _drawHeader(bill, companyInfo, page, pageSize, grid);
    _drawGrid(page, grid, result, bill, pageSize);
    _drawFooter(document.pages[document.pages.count - 1], pageSize, companyInfo, bill);
    return document;
  }

  Future savePdf(Bill bill) async {
    Directory directory = await getApplicationDocumentsDirectory();
    PdfDocument document = await makePdf(bill);
    File('${directory.path}\\${bill.clientName.toLowerCase() + "-" + bill.amountGrand.toInt().toString() + "-" + bill.billDate.split(" ")[0]}.pdf')
        .writeAsBytes(document.save())
        .whenComplete(() => print("SAVED " + '${directory.path}\\test.pdf'));
    document.dispose();
  }

  Future printPdf(Bill bill) async {
    PdfDocument document = await makePdf(bill);
    await Printing.layoutPdf(onLayout: (format) async => document.save());
    document.dispose();
  }

  PdfLayoutResult _drawHeader(Bill bill, CompanyInfo companyInfo, PdfPage page, Size pageSize, PdfGrid grid) {
    PdfFont font = PdfStandardFont(PdfFontFamily.timesRoman, 25, style: PdfFontStyle.bold);
    page.graphics.drawRectangle(brush: PdfSolidBrush(PdfColor(91, 155, 213)), bounds: Rect.fromLTWH(0, 0, pageSize.width, 90));
    page.graphics.drawString(companyInfo.companyName.toUpperCase(), font,
        brush: PdfBrushes.white, bounds: Rect.fromLTWH(0, 20, pageSize.width, 90), format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.top, alignment: PdfTextAlignment.center));
    page.graphics.drawString(companyInfo.companyAddress + " M: ${companyInfo.companyNumber}", PdfStandardFont(PdfFontFamily.timesRoman, 16),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(0, font.measureString(companyInfo.companyName.toUpperCase()).height + 20, pageSize.width, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.top, alignment: PdfTextAlignment.center));
    page.graphics.drawString("TAX INVOICE", PdfStandardFont(PdfFontFamily.helvetica, 20, multiStyle: [PdfFontStyle.italic, PdfFontStyle.bold]),
        brush: PdfSolidBrush(PdfColor(91, 155, 213)),
        bounds: Rect.fromLTWH(0, 92, pageSize.width, 30),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.top, alignment: PdfTextAlignment.center));
    page.graphics.drawLine(PdfPen.fromBrush(PdfSolidBrush(PdfColor(91, 155, 213))), Offset(0, 120), Offset(pageSize.width, 120));
    if (companyInfo.companyGSTINNo != "") {
      page.graphics.drawString("GST NO.: ${companyInfo.companyGSTINNo}", PdfStandardFont(PdfFontFamily.helvetica, 16, multiStyle: [PdfFontStyle.italic, PdfFontStyle.bold]),
          brush: PdfSolidBrush(PdfColor(91, 155, 213)),
          bounds: Rect.fromLTWH(0, 125, pageSize.width, 30),
          format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.top, alignment: PdfTextAlignment.center));
      page.graphics.drawLine(PdfPen.fromBrush(PdfSolidBrush(PdfColor(91, 155, 213))), Offset(0, 150), Offset(pageSize.width, 150));
    }
    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final String invoiceNumber = 'Invoice Number: ${bill.invoiceNo}\r\n\r\nDate: ' + DateFormat("dd MMM, yyyy").format(DateTime.parse(bill.invoiceDate));
    final Size contentSize = contentFont.measureString(invoiceNumber);
    String info = 'Bill To: ${bill.clientName}\r\n\nAddress: ${bill.clientAddress}\r\n\nGSTIN No.: ${bill.clientGSTIN}\r\n\nState: ${bill.clientState}\t\tCode: ${bill.clientCode}';
    PdfTextElement(text: invoiceNumber, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(
            pageSize.width - (contentSize.width + 30), companyInfo.companyGSTINNo != "" ? 170 : 140, contentSize.width + 30, pageSize.height - (companyInfo.companyGSTINNo != "" ? 170 : 140)));
    return PdfTextElement(text: info, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(30, companyInfo.companyGSTINNo != "" ? 170 : 140, pageSize.width - (contentSize.width + 30), pageSize.height - (companyInfo.companyGSTINNo != "" ? 170 : 140)));
  }

  void _drawFooter(PdfPage page, Size pageSize, CompanyInfo companyInfo, Bill bill) {
    List<int> taxes = [];
    bill.parts.forEach((e) {
      if (!taxes.contains(e.part.tax)) taxes.add(e.part.tax);
    });
    double height = 0;
    PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    page.graphics.drawString('Total Invoice value in words:\n\n${NumberToWord().convert("en-in", bill.amountGrand.toInt()).capitalizeFirstOfEach}.', font,
        bounds: Rect.fromLTWH(10, pageSize.height - 320, 0, 0), format: PdfStringFormat(alignment: PdfTextAlignment.left));
    page.graphics.drawString('Amount before GST: ${bill.amountBfTax} Rs.', font,
        bounds: Rect.fromLTWH(pageSize.width - 10, pageSize.height - 320, 0, 0), format: PdfStringFormat(alignment: PdfTextAlignment.right));
    taxes.forEach((e) {
      List<PartWithQuantity> _parts = [];
      _parts.addAll(bill.parts.where((ee) => ee.part.tax == e));
      height += font.measureString('Add : ${bill.taxType} @ $e%: ${calculateTax(_parts).toStringAsFixed(2)} Rs.').height;
      return page.graphics.drawString('Add : ${bill.taxType} @ $e%: ${calculateTax(_parts).toStringAsFixed(2)} Rs.', font,
          bounds: Rect.fromLTWH(pageSize.width - 10, pageSize.height - 320 + height, 0, 0), format: PdfStringFormat(alignment: PdfTextAlignment.right));
    });
    height += font.measureString('Amount before GST: ${bill.amountBfTax} Rs.').height;
    page.graphics.drawString('Grand Total: ${bill.amountGrand.toStringAsFixed(2)} Rs.', font,
        bounds: Rect.fromLTWH(pageSize.width - 10, pageSize.height - 320 + height, 0, 0), format: PdfStringFormat(alignment: PdfTextAlignment.right));
    final PdfPen linePen = PdfPen(PdfColor(91, 155, 213, 255), dashStyle: PdfDashStyle.custom);
    linePen.dashPattern = <double>[3, 3];
    page.graphics.drawString('BANK NAME: ${companyInfo.bankName}\nA/C No: ${companyInfo.bankAccountNo}\nIFS Code: ${companyInfo.ifsCode}', font,
        bounds: Rect.fromLTWH(10, pageSize.height - 150, 0, 0), format: PdfStringFormat(alignment: PdfTextAlignment.left));
    page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100), Offset(pageSize.width, pageSize.height - 100));
    String footerContent = 'For, ${companyInfo.companyName}\n\n\n\n\nAuthorized Signatory';
    const String termsAndConditions =
        'Terms & Conditions:\n1. All disputes are subject to Delhi Jurisdiction only.\n2. Goods will be supplied at purchaser\'s risk only.\n3. In case of return cheque Rs. 150/- will be charged as per Bank Charges.\n4.Goods once sold will not be taken back.';
    page.graphics.drawString(termsAndConditions, PdfStandardFont(PdfFontFamily.helvetica, 10),
        format: PdfStringFormat(alignment: PdfTextAlignment.left), bounds: Rect.fromLTWH(10, pageSize.height - 65, pageSize.width - 80, 0));
    page.graphics.drawString(footerContent, PdfStandardFont(PdfFontFamily.helvetica, 12),
        format: PdfStringFormat(alignment: PdfTextAlignment.right), bounds: Rect.fromLTWH(pageSize.width - 10, pageSize.height - 90, 0, 0));
  }

  _drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result, Bill bill, Size pageSize) {
    result = grid.draw(page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 20, 0, 0));
  }

  PdfGrid _getGrid(Bill bill) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 6);
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(91, 155, 213));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.style.font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    headerRow.cells[0].value = 'Sr No.';
    headerRow.cells[1].value = 'Product Name';
    headerRow.cells[2].value = 'Quantity';
    headerRow.cells[3].value = 'Price (Rs.)';
    headerRow.cells[4].value = 'GST (%)';
    headerRow.cells[5].value = 'Taxable Val (Rs.)';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[2].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[3].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[4].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[5].stringFormat.alignment = PdfTextAlignment.center;
    bill.parts.forEach((e) => _addProducts((bill.parts.indexOf(e) + 1).toString(), e.part.name, e.quantity, e.part.price, e.part.tax, (e.part.price * e.quantity), grid));
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent1);
    grid.columns[1].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding = PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.style.font = PdfStandardFont(PdfFontFamily.helvetica, 10);
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding = PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  void _addProducts(String productId, String productName, int quantity, int price, int tax, int total, PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = productId;
    row.cells[1].value = productName;
    row.cells[2].value = quantity.toString();
    row.cells[3].value = price.toString();
    row.cells[4].value = tax.toString();
    row.cells[5].value = total.toString();
    row.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    row.cells[2].stringFormat.alignment = PdfTextAlignment.center;
    row.cells[3].stringFormat.alignment = PdfTextAlignment.center;
    row.cells[4].stringFormat.alignment = PdfTextAlignment.center;
    row.cells[5].stringFormat.alignment = PdfTextAlignment.center;
    row.cells[0].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10);
    row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10);
    row.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10);
    row.cells[3].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10);
    row.cells[4].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10);
    row.cells[5].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10);
  }

  searchBill(String text) {
    if (text.isNotEmpty) {
      _isSearching = true;
      _searchedBills = _bills.where((e) => e.toJson().toString().toLowerCase().contains(text.toLowerCase())).toList();
    } else
      _isSearching = false;
    notifyListeners();
  }

  double calculateGrandTotal(List<PartWithQuantity> parts) {
    double total = 0;
    parts.forEach((e) => total += (e.part.price * e.quantity) + ((e.part.tax / 100) * (e.part.price * e.quantity)));
    return total;
  }

  double calculateTax(List<PartWithQuantity> parts) {
    double total = 0;
    parts.forEach((e) => total += ((e.part.tax / 100) * (e.part.price * e.quantity)));
    return total;
  }

  int calculateBeforeTax(List<PartWithQuantity> parts) {
    int total = 0;
    parts.forEach((e) => total += (e.part.price * e.quantity));
    return total;
  }

  int totalItems(List<PartWithQuantity> parts) {
    int total = 0;
    parts.forEach((e) => total += e.quantity);
    return total;
  }

  setViewingIndex(int index) {
    _viewingIndex = index;
    notifyListeners();
  }
}

class SettingsChangeNotifier extends ChangeNotifier {
  CompanyInfo _companyInfo;
  CompanyInfo get companyInfo => _companyInfo;

  Future<CompanyInfo> getData() async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}\\info.json');
    String json = await file.readAsString();
    _companyInfo = CompanyInfo.fromJson(jsonDecode(json));
    notifyListeners();
    return _companyInfo;
  }

  Future saveData(CompanyInfo companyInfo) async {
    Directory directory = await getApplicationSupportDirectory();
    File file = File('${directory.path}\\info.json');
    file.writeAsString(jsonEncode(companyInfo).toString()).whenComplete(() => print("SAVED " + '${directory.path}\\info.json'));
    getData();
  }
}

/*
extension CapExtension on String {
  String get inCaps => this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  String get capitalizeFirstOfEach => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
}
*/
