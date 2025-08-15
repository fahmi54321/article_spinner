import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TextSpinnerState extends ChangeNotifier {
  final TextEditingController controller = TextEditingController();

  String spunText = "";
  String? hoveredOld;
  String? hoveredNew;

  bool isLoading = false;

  List<Map<String, String>> replacements = [];

  List<InlineSpan> buildColoredText(String text) {
    // Mencari teks di dalam tanda < > (contoh: <Hello> akan ketemu Hello).
    final regex = RegExp(r'<(.*?)>');

    // spans → daftar hasil akhir dalam bentuk InlineSpan (bisa TextSpan atau WidgetSpan).
    final spans = <InlineSpan>[];

    // lastEnd → untuk melacak posisi terakhir yang sudah diproses, supaya bisa ambil teks di antaranya.
    int lastEnd = 0;

    // hoveredWordOld & hoveredWordNew → kata yang sedang di-hover (dari variabel global/state).
    final hoveredWordOld = hoveredOld;
    final hoveredWordNew = hoveredNew;

    for (final match in regex.allMatches(text)) {
      // Sebelum <tag> → ambil teks biasa (di luar tag) dan kirim ke _splitAndBox dengan isNew = false.
      if (match.start > lastEnd) {
        // Dalam <tag> → ambil kata di dalam tanda < > (match.group(1)) dan kirim ke _splitAndBox dengan isNew = true (artinya ini kata new).
        final normalText = text.substring(lastEnd, match.start);
        spans.addAll(
          _splitAndBox(normalText, hoveredWordOld, hoveredWordNew, false),
        );
      }

      final newWord = match.group(1)!;
      spans.addAll(_splitAndBox(newWord, hoveredWordOld, hoveredWordNew, true));

      lastEnd = match.end;
    }

    // Kalau masih ada teks setelah tag terakhir, diproses seperti biasa (bukan new).
    if (lastEnd < text.length) {
      final normalText = text.substring(lastEnd);
      spans.addAll(
        _splitAndBox(normalText, hoveredWordOld, hoveredWordNew, false),
      );
    }

    return spans;
  }

  // Memecah teks per kata dan memutuskan apakah kata tersebut perlu dibungkus kotak atau tidak.
  List<InlineSpan> _splitAndBox(
    String text,
    String? hoveredOld,
    String? hoveredNew,
    bool isNew,
  ) {
    // mendeteksi kata (\w+) dengan batas kata (\b), jadi tidak ikut spasi/punctuation.
    final wordRegex = RegExp(r'(\b\w+\b)');

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in wordRegex.allMatches(text)) {
      // Tambahkan spasi/punctuation sebelum kata
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      }

      final word = match.group(0)!;
      final isHoveredOld = hoveredOld != null && word == hoveredOld;
      final isHoveredNew = hoveredNew != null && word == hoveredNew;

      // Jika kata di-hover → bungkus dengan kotak
      if (isHoveredOld || isHoveredNew) {
        spans.add(
          WidgetSpan(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isHoveredOld
                    ? Colors.blue.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                border: Border.all(
                  color: isHoveredOld ? Colors.blue : Colors.orange,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                word,
                style: TextStyle(
                  color: isNew ? Colors.yellow : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }
      // Jika kata tidak di-hover → teks biasa
      else {
        spans.add(
          TextSpan(
            text: word,
            style: TextStyle(
              color: isNew ? Colors.yellow : Colors.white,
              fontSize: 16,
            ),
          ),
        );
      }

      lastEnd = match.end;
    }

    // Menambahkan tanda baca atau spasi di akhir.
    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return spans;
  }

  void updateIsLoading({required bool val}) {
    isLoading = val;
    notifyListeners();
  }

  void updateSpunText({required String val}) {
    spunText = val;
    notifyListeners();
  }

  void updateReplacements({required List<Map<String, String>> val}) {
    replacements = val;
    notifyListeners();
  }

  void spinText() async {
    updateIsLoading(val: true);

    final url = Uri.parse('http://127.0.0.1:5000/spin');
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": controller.text}),
    );

    await Future.delayed(Duration(seconds: 2));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      updateSpunText(val: data["spun_text"]);
      updateReplacements(
        val: (data["replaceable_words"] as List)
            .map(
              (e) => {
                "old_word": e["old_word"].toString(),
                "new_word": e["new_word"].toString(),
              },
            )
            .toList(),
      );
      debugPrint('spun text: $spunText');
      debugPrint('replacements: $replacements');
      updateIsLoading(val: false);
    } else {
      debugPrint("Error: ${res.statusCode}");
      updateIsLoading(val: false);
    }
  }

  void replaceWord(String oldWord, String newWord) {
    final regex = RegExp(
      r'\b' + RegExp.escape(oldWord) + r'\s*<' + RegExp.escape(newWord) + r'>',
    );
    updateHoveredNew(val: null);
    updateHoveredOld(val: null);
    updateSpunText(val: spunText.replaceFirst(regex, newWord));

    /**
 
    r'...'
    Awalan r artinya raw string, sehingga karakter \ di dalamnya tidak diinterpretasikan 
    sebagai escape sequence oleh Dart (jadi \n dibaca apa adanya, bukan newline).

    \b
    Ini adalah word boundary — menandakan batas kata.
    Jadi pencarian \bcat tidak akan cocok dengan concatenate, 
    hanya cocok dengan kata cat yang berdiri sendiri atau diapit spasi/tanda baca.

    RegExp.escape(oldWord)
    Fungsi ini akan meng-escape karakter spesial dalam regex dari oldWord.
    Contoh: kalau oldWord = "C++", tanpa escape + akan dianggap simbol regex. 
    Dengan escape, regex akan mencari C\+\+ sehingga benar-benar cocok hanya untuk teks C++.

    \s*
    Ini artinya "nol atau lebih spasi" (whitespace characters).
    Jadi boleh tidak ada spasi, atau ada satu/lebih spasi/tab.

    < dan >
    Karakter ini literal, digunakan untuk mencari tanda kurung sudut di teks.

    RegExp.escape(newWord)
    Sama seperti oldWord, ini memastikan newWord aman di regex.

  */
  }

  void updateHoveredOld({required String? val}) {
    hoveredOld = val;
    notifyListeners();
  }

  void updateHoveredNew({required String? val}) {
    hoveredNew = val;
    notifyListeners();
  }

  void previewReplacement(String oldWord, String newWord) {
    updateHoveredNew(val: newWord);
    updateHoveredOld(val: oldWord);
  }

  void clearPreview() {
    updateHoveredNew(val: null);
    updateHoveredOld(val: null);
  }
}
