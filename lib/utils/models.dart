class Part {
  int id, price, tax, cachePrice, cacheTax;
  String name;
  bool isSelected, isEditingPrice, isEditingTax;

  Part({this.id, this.name, this.price, this.tax, this.cachePrice = 0, this.cacheTax = 0, this.isSelected = false, this.isEditingPrice = false, this.isEditingTax = false});

  Map<String, dynamic> toJson() => {"id": this.id, "name": this.name, "price": this.price, "tax": this.tax};

  factory Part.fromJson(dynamic json) => Part(id: json["id"] as int, name: json["name"] as String, price: json["price"] as int, tax: json["tax"] as int);
}

class PartWithQuantity {
  Part part;
  int quantity;

  Map<String, dynamic> toJson() => {"part": this.part, "quantity": this.quantity};

  factory PartWithQuantity.fromJson(dynamic json) => PartWithQuantity(part: json["part"] as Part, quantity: json["quantity"] as int);

  PartWithQuantity({this.part, this.quantity});
}

class Bill {
  int invoiceNo, clientCode, amountBfTax;
  double amountGrand;
  String clientName, clientAddress, clientGSTIN, clientState, invoiceDate, billDate, taxType;
  List<PartWithQuantity> parts;
  bool isPaid;

  Map<String, dynamic> toJson() => {
        "invoiceNo": this.invoiceNo,
        "clientCode": this.clientCode,
        "amountBfTax": this.amountBfTax,
        "amountGrand": this.amountGrand,
        "invoiceDate": this.invoiceDate,
        "billDate": this.billDate,
        "clientName": this.clientName,
        "clientAddress": this.clientAddress,
        "clientGSTIN": this.clientGSTIN,
        "clientState": this.clientState,
        "parts": this.parts,
        "taxType": this.taxType,
        "isPaid": this.isPaid
      };

  factory Bill.fromJson(dynamic json) => Bill(
      amountBfTax: json["amountBfTax"] as int,
      amountGrand: json["amountGrand"] as double,
      billDate: json["billDate"] as String,
      invoiceDate: json["invoiceDate"] as String,
      clientAddress: json["clientAddress"] as String,
      clientCode: json["clientCode"] as int,
      clientGSTIN: json["clientGSTIN"] as String,
      clientName: json["clientName"] as String,
      clientState: json["clientState"] as String,
      invoiceNo: json["invoiceNo"] as int,
      isPaid: json["isPaid"] as bool,
      taxType: json["taxType"] as String,
      parts: List<Map<String, dynamic>>.from(json['parts']).map((e) => PartWithQuantity(part: Part.fromJson(e['part']), quantity: e['quantity'] as int)).toList());

  Bill(
      {this.invoiceNo,
      this.clientCode,
      this.invoiceDate,
      this.billDate,
      this.parts,
      this.clientAddress,
      this.clientGSTIN,
      this.clientName,
      this.clientState,
      this.isPaid = false,
      this.amountBfTax,
      this.taxType,
      this.amountGrand});
}

class CompanyInfo {
  String companyName, companyAddress, companyNumber, companyGSTINNo, bankName, bankAccountNo, ifsCode;

  Map<String, dynamic> toJson() => {
        "companyName": this.companyName,
        "companyAddress": this.companyAddress,
        "companyNumber": this.companyNumber,
        "companyGSTINNo": this.companyGSTINNo,
        "bankName": this.bankName,
        "bankAccountNo": this.bankAccountNo,
        "ifsCode": this.ifsCode
      };

  factory CompanyInfo.fromJson(dynamic json) => CompanyInfo(
      companyName: json["companyName"],
      companyAddress: json["companyAddress"],
      companyGSTINNo: json["companyGSTINNo"],
      companyNumber: json["companyNumber"],
      bankName: json["bankName"],
      bankAccountNo: json["bankAccountNo"],
      ifsCode: json["ifsCode"]);

  CompanyInfo({this.companyName, this.companyAddress, this.companyNumber, this.companyGSTINNo, this.bankName, this.bankAccountNo, this.ifsCode});
}
