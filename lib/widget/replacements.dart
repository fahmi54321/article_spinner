// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:article_spinner/text_spinner_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class Replacements extends StatelessWidget {
  final TextSpinnerState state;
  const Replacements({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replacements',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: state.isLoading
                      ? ListView.builder(
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade700,
                                highlightColor: Colors.grey.shade500,
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: state.replacements.length,
                          itemBuilder: (context, index) {
                            final item = state.replacements[index];
                            return MouseRegion(
                              onEnter: (_) {
                                debugPrint(
                                  'Hovered: ${item['old_word']} → ${item['new_word']}',
                                );
                                state.previewReplacement(
                                  item['old_word']!,
                                  item['new_word']!,
                                );
                              },
                              onExit: (_) {
                                debugPrint('Exited hover');
                                state.clearPreview();
                              },
                              child: ListTile(
                                title: Text(
                                  "${item['old_word']} → ${item['new_word']}",
                                  style: const TextStyle(color: Colors.white),
                                ),

                                onTap: () {
                                  state.replaceWord(
                                    item['old_word'] ?? "",
                                    item['new_word'] ?? "",
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
