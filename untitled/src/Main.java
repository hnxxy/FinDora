import 'package:flutter/material.dart';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
                title: 'Tracking App',
                theme: ThemeData(
                primarySwatch: Colors.pink,
                useMaterial3: true,
      ),
        home: const HomeScreen(),
                debugShowCheckedModeBanner: false,
    );
    }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
                body: SafeArea(
                child: Column(
                children: [
        // Header
        Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
                color: Colors.pink[200],
              ),
        child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
        Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        Text(
                '07:00',
                style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                        ),
                      ),
                      const Text(
                'HOME',
                style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
        Icon(
                Icons.notifications,
                color: Colors.white.withOpacity(0.9),
                size: 24,
                  ),
                ],
              ),
            ),

        // Map Section
        Expanded(
                flex: 3,
                child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                color: const Color(0xFF1e3a5f),
                ),
        child: Stack(
                children: [
        // Map pattern background
        CustomPaint(
                size: Size.infinite,
                painter: MapPatternPainter(),
                    ),
        // Markers
        Positioned(
                left: 80,
                top: 100,
                child: Column(
                children: [
                          const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
                          ),
        Container(
                padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
                            ),
        decoration: BoxDecoration(
                color: const Color(0xFF2a4a6f),
                borderRadius: BorderRadius.circular(4),
                            ),
        child: const Text(
                'Saya',
                style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        // Location labels
                    const Positioned(
                right: 30,
                top: 120,
                child: Text(
                'Plaza Ambarru',
                style: TextStyle(
                color: Colors.white60,
                fontSize: 18,
                        ),
                      ),
                    ),
                    const Positioned(
                right: 30,
                bottom: 80,
                child: Text(
                'Asram',
                style: TextStyle(
                color: Colors.white60,
                fontSize: 18,
                        ),
                      ),
                    ),
                    const Positioned(
                right: 30,
                bottom: 50,
                child: Text(
                'Lancik',
                style: TextStyle(
                color: Colors.white60,
                fontSize: 18,
                        ),
                      ),
                    ),
        Positioned(
                right: 30,
                bottom: 20,
                child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

        // Bottom Section
        Expanded(
                flex: 2,
                child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                color: Colors.pink[200],
                ),
        child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
        // Device Info Card
        Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                      ),
        child: Row(
                children: [
        Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                color: Colors.pink[100],
                shape: BoxShape.circle,
                            ),
        child: Icon(
                Icons.vpn_key,
                color: Colors.pink[300],
                            ),
                          ),
                          const SizedBox(width: 12),
        Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                const Text(
                'KEY',
                style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                                  ),
                                ),
        Row(
                children: [
                                    const Text(
                'Online',
                style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
        Container(
                width: 30,
                height: 15,
                decoration: BoxDecoration(
                border: Border.all(
                color: Colors.grey,
                width: 1,
                                        ),
        borderRadius: BorderRadius.circular(2),
                                      ),
        child: Stack(
                children: [
        Container(
                margin: const EdgeInsets.all(1),
                width: 20,
                decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
        BorderRadius.circular(1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                Icons.chevron_right,
                size: 30,
                          ),
                        ],
                      ),
                    ),

        // Add Item Button
        ElevatedButton(
                onPressed: () {},
        style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4C5C),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                        ),
                      ),
        child: const Text(
                'Tambahkan Barang',
                style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Colors.pink[200],
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white70,
                items: const [
        BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '',
          ),
        BottomNavigationBarItem(
                icon: Icon(Icons.send),
                label: '',
          ),
        BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '',
          ),
        ],
      ),
    );
    }
}

// Custom painter for map pattern
class MapPatternPainter extends CustomPainter {
    @override
    void paint(Canvas canvas, Size size) {
        final paint = Paint()
                ..color = Colors.white.withOpacity(0.1)
                ..strokeWidth = 1.5
                ..style = PaintingStyle.stroke;

        // Draw grid pattern to simulate map
        for (double i = 0; i < size.width; i += 30) {
            canvas.drawLine(
                    Offset(i, 0),
                    Offset(i, size.height),
                    paint,
                    );
        }

        for (double i = 0; i < size.height; i += 30) {
            canvas.drawLine(
                    Offset(0, i),
                    Offset(size.width, i),
                    paint,
                    );
        }

        // Draw some random paths to simulate streets
        final pathPaint = Paint()
                ..color = Colors.white.withOpacity(0.15)
                ..strokeWidth = 2
                ..style = PaintingStyle.stroke;

        final path = Path();
        path.moveTo(0, size.height * 0.3);
        path.lineTo(size.width, size.height * 0.3);
        canvas.drawPath(path, pathPaint);

        final path2 = Path();
        path2.moveTo(size.width * 0.4, 0);
        path2.lineTo(size.width * 0.4, size.height);
        canvas.drawPath(path2, pathPaint);
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}