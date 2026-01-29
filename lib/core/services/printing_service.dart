import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class PrintingService {
  /// Print a PDF document
  Future<void> printPdf(String title, pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: title,
    );
  }

  /// Print an image
  Future<void> printImage(String title, List<int> imageBytes) async {
    final uint8List = Uint8List.fromList(imageBytes);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => uint8List,
      name: title,
    );
  }
}
