import 'package:flutter/material.dart';

/// Alias for backwards compatibility
typedef JadwalKuliah = JadwalPage;

/// Main schedule page (Jadwal)
class JadwalPage extends StatelessWidget {
  const JadwalPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E222B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282D37),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
      children: [
        Container(
          width: 390,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFF282D37),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36),
            ),
            shadows: [
              const BoxShadow(
                color: const Color(0x8C000000),
                blurRadius: 50,
                offset: const Offset(0, 25),
                spreadRadius: -12,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 390,

                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 22,
                  children: [
                    Container(
                      width: 390,
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(color: Color(0xFF282D37)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '08:12',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            '● 4G  ▰',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 166,
                        children: [
                          Container(
                            width: 91.80,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                const SizedBox(
                                  width: 91.80,
                                  height: 27,
                                  child: const Text(
                                    'Hi Jarvis',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFF323846),
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'JS',
                                  style: TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 350,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 12,
                        children: [
                          Container(
                            height: 25,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFA6144) /* Primary */,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                const Text(
                                  'All',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 25,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Text(
                                  'Today',
                                  style: TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 25,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Text(
                                  'Week',
                                  style: TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 25,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Text(
                                  'Month',
                                  style: TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFA6144) /* Primary */,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Add Schedule',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 350,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 13,
                        children: [
                          Container(
                            width: double.infinity,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 144,
                              children: [
                                Text(
                                  'Today 12 Oct',
                                  style: TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 18),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 9,
                              children: [
                                Container(
                                  width: 5,
                                  height: double.infinity,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 5,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFF826E) /* Primary-3 */,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 318,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 9,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 18,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 105,
                                          children: [
                                            const Text(
                                              'UBXCCB2 - BAHASA INDONESIA',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.55,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.20,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFFF826E) /* Primary-3 */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 10,
                                                children: [
                                                  const Text(
                                                    'Ongoing',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9.53,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 318,
                                        height: 13,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'KTT B-106 ',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '• ',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'SSIF-04-REG-GAB02',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 15,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 98,
                                          children: [
                                            Container(
                                              width: 120.08,
                                              height: 15,
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 15,
                                                      height: 15,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFFFF7D65) /* Primary-2 */,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(7.50),
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            left: 3,
                                                            top: 3,
                                                            child: Container(
                                                              width: 9,
                                                              height: 9,
                                                              clipBehavior: Clip.antiAlias,
                                                              decoration: const BoxDecoration(),
                                                              child: const Stack(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    left: 21,
                                                    top: 1.50,
                                                    child: Text(
                                                      '09:30 - 11: 30 WIB',
                                                      style: TextStyle(
                                                        color: Color(0xFF8E95A5),
                                                        fontSize: 10.78,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 18),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 9,
                              children: [
                                Container(
                                  width: 5,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 5,
                                          decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 318,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 9,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 18,
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 105,
                                          children: [
                                            const Text(
                                              'UBXCCB2 - BAHASA INDONESIA',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.55,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 318,
                                        height: 13,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'KTT B-106 ',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '• ',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'SSIF-04-REG-GAB02',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 15,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 98,
                                          children: [
                                            Container(
                                              width: 120.08,
                                              height: 15,
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 15,
                                                      height: 15,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF8E95A5),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(7.50),
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            left: 3,
                                                            top: 3,
                                                            child: Container(
                                                              width: 9,
                                                              height: 9,
                                                              clipBehavior: Clip.antiAlias,
                                                              decoration: const BoxDecoration(),
                                                              child: const Stack(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    left: 21,
                                                    top: 1.50,
                                                    child: Text(
                                                      '09:30 - 11: 30 WIB',
                                                      style: TextStyle(
                                                        color: Color(0xFF8E95A5),
                                                        fontSize: 10.78,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 18),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 9,
                              children: [
                                Container(
                                  width: 5,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 5,
                                          decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 318,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 9,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 18,
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 105,
                                          children: [
                                            const Text(
                                              'UBXCCB2 - BAHASA INDONESIA',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.55,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 318,
                                        height: 13,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'KTT B-106 ',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '• ',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'SSIF-04-REG-GAB02',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 15,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 98,
                                          children: [
                                            Container(
                                              width: 120.08,
                                              height: 15,
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 15,
                                                      height: 15,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF8E95A5),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(7.50),
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            left: 3,
                                                            top: 3,
                                                            child: Container(
                                                              width: 9,
                                                              height: 9,
                                                              clipBehavior: Clip.antiAlias,
                                                              decoration: const BoxDecoration(),
                                                              child: const Stack(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    left: 21,
                                                    top: 1.50,
                                                    child: Text(
                                                      '09:30 - 11: 30 WIB',
                                                      style: TextStyle(
                                                        color: Color(0xFF8E95A5),
                                                        fontSize: 10.78,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 350,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 13,
                        children: [
                          Container(
                            width: double.infinity,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 144,
                              children: [
                                Text(
                                  'Selasa 13 Oct',
                                  style: TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 18),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 9,
                              children: [
                                Container(
                                  width: 5,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 5,
                                          decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 318,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 9,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 18,
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 105,
                                          children: [
                                            const Text(
                                              'MEETING IMPAL',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.55,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 318,
                                        height: 13,
                                        child: Text(
                                          'Discord - Group IMPAL',
                                          style: TextStyle(
                                            color: Color(0xFF8E95A5),
                                            fontSize: 11,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 15,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 98,
                                          children: [
                                            Container(
                                              width: 120.08,
                                              height: 15,
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 15,
                                                      height: 15,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF8E95A5),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(7.50),
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            left: 3,
                                                            top: 3,
                                                            child: Container(
                                                              width: 9,
                                                              height: 9,
                                                              clipBehavior: Clip.antiAlias,
                                                              decoration: const BoxDecoration(),
                                                              child: const Stack(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    left: 21,
                                                    top: 1.50,
                                                    child: Text(
                                                      'Tomorrow 19:00 WIB',
                                                      style: TextStyle(
                                                        color: Color(0xFF8E95A5),
                                                        fontSize: 10.78,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 18),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 9,
                              children: [
                                Container(
                                  width: 5,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 5,
                                          decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 318,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 9,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 18,
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 105,
                                          children: [
                                            const Text(
                                              'MEETING IMPAL',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.55,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 318,
                                        height: 13,
                                        child: Text(
                                          'Discord - Group IMPAL',
                                          style: TextStyle(
                                            color: Color(0xFF8E95A5),
                                            fontSize: 11,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 15,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 98,
                                          children: [
                                            Container(
                                              width: 120.08,
                                              height: 15,
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 15,
                                                      height: 15,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF8E95A5),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(7.50),
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            left: 3,
                                                            top: 3,
                                                            child: Container(
                                                              width: 9,
                                                              height: 9,
                                                              clipBehavior: Clip.antiAlias,
                                                              decoration: const BoxDecoration(),
                                                              child: const Stack(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    left: 21,
                                                    top: 1.50,
                                                    child: Text(
                                                      'Tomorrow 19:00 WIB',
                                                      style: TextStyle(
                                                        color: Color(0xFF8E95A5),
                                                        fontSize: 10.78,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 18),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 9,
                              children: [
                                Container(
                                  width: 5,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 5,
                                          decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 318,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 9,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 18,
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 105,
                                          children: [
                                            const Text(
                                              'UBXCCB2 - BAHASA INDONESIA',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.55,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 318,
                                        height: 13,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'KTT B-106 ',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '• ',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'SSIF-04-REG-GAB02',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 15,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 98,
                                          children: [
                                            Container(
                                              width: 120.08,
                                              height: 15,
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 15,
                                                      height: 15,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF8E95A5),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(7.50),
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            left: 3,
                                                            top: 3,
                                                            child: Container(
                                                              width: 9,
                                                              height: 9,
                                                              clipBehavior: Clip.antiAlias,
                                                              decoration: const BoxDecoration(),
                                                              child: const Stack(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    left: 21,
                                                    top: 1.50,
                                                    child: Text(
                                                      '09:30 - 11: 30 WIB',
                                                      style: TextStyle(
                                                        color: Color(0xFF8E95A5),
                                                        fontSize: 10.78,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 350,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 13,
                        children: [
                          Container(
                            width: double.infinity,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 144,
                              children: [
                                Text(
                                  'Next Month 23 Nov',
                                  style: TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 18),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 9,
                              children: [
                                Container(
                                  width: 5,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 5,
                                          decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 318,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 9,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 18,
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 105,
                                          children: [
                                            const Text(
                                              'UBXCCB2 - BAHASA INDONESIA',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.55,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 318,
                                        height: 13,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'KTT B-106 ',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '• ',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'SSIF-04-REG-GAB02',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 15,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 98,
                                          children: [
                                            Container(
                                              width: 120.08,
                                              height: 15,
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 15,
                                                      height: 15,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF8E95A5),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(7.50),
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            left: 3,
                                                            top: 3,
                                                            child: Container(
                                                              width: 9,
                                                              height: 9,
                                                              clipBehavior: Clip.antiAlias,
                                                              decoration: const BoxDecoration(),
                                                              child: const Stack(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    left: 21,
                                                    top: 1.50,
                                                    child: Text(
                                                      '09:30 - 11: 30 WIB',
                                                      style: TextStyle(
                                                        color: Color(0xFF8E95A5),
                                                        fontSize: 10.78,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 18),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 9,
                              children: [
                                Container(
                                  width: 5,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 5,
                                          decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 318,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 9,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 18,
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 105,
                                          children: [
                                            const Text(
                                              'MEETING IMPAL',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.55,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 318,
                                        height: 13,
                                        child: Text(
                                          'Discord - Group IMPAL',
                                          style: TextStyle(
                                            color: Color(0xFF8E95A5),
                                            fontSize: 11,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 15,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 98,
                                          children: [
                                            Container(
                                              width: 120.08,
                                              height: 15,
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 15,
                                                      height: 15,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF8E95A5),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(7.50),
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            left: 3,
                                                            top: 3,
                                                            child: Container(
                                                              width: 9,
                                                              height: 9,
                                                              clipBehavior: Clip.antiAlias,
                                                              decoration: const BoxDecoration(),
                                                              child: const Stack(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    left: 21,
                                                    top: 1.50,
                                                    child: Text(
                                                      'Tomorrow 19:00 WIB',
                                                      style: TextStyle(
                                                        color: Color(0xFF8E95A5),
                                                        fontSize: 10.78,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 18),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF323846),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 9,
                              children: [
                                Container(
                                  width: 5,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 5,
                                          decoration: const BoxDecoration(color: Color(0xFF8E95A5)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 318,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 9,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 18,
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 105,
                                          children: [
                                            const Text(
                                              'UBXCCB2 - BAHASA INDONESIA',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.55,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 318,
                                        height: 13,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'KTT B-106 ',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '• ',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'SSIF-04-REG-GAB02',
                                                style: TextStyle(
                                                  color: Color(0xFF8E95A5),
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 15,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 98,
                                          children: [
                                            Container(
                                              width: 120.08,
                                              height: 15,
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 15,
                                                      height: 15,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF8E95A5),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(7.50),
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            left: 3,
                                                            top: 3,
                                                            child: Container(
                                                              width: 9,
                                                              height: 9,
                                                              clipBehavior: Clip.antiAlias,
                                                              decoration: const BoxDecoration(),
                                                              child: const Stack(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    left: 21,
                                                    top: 1.50,
                                                    child: Text(
                                                      '09:30 - 11: 30 WIB',
                                                      style: TextStyle(
                                                        color: Color(0xFF8E95A5),
                                                        fontSize: 10.78,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 390,
                height: 100,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 20,
                      child: Container(
                        width: 390,
                        height: 80,
                        decoration: const ShapeDecoration(
                          color: Color(0xFF323846),
                          shape: const RoundedRectangleBorder(
                            borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(5),
                              topRight: const Radius.circular(5),
                              bottomLeft: const Radius.circular(30),
                              bottomRight: const Radius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 57,
                      top: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 27,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 60,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(),
                                child: const Stack(),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(),
                                child: const Stack(),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  image: const DecorationImage(
                                    image: const NetworkImage("https://placehold.co/24x24"),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 58,
                            height: 58,
                            decoration: const ShapeDecoration(
                              gradient: LinearGradient(
                                begin: const Alignment(0.50, -0.00),
                                end: const Alignment(0.50, 1.00),
                                colors: [Color(0xFFFD7357), Color(0xFFFA6144)],
                              ),
                              shape: const OvalBorder(),
                              shadows: [
                                const BoxShadow(
                                  color: const Color(0x58FA6144),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(),
                            child: const Stack(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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