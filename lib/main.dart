import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const AlgoritmosApp());

class AlgoritmosApp extends StatelessWidget {
  const AlgoritmosApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Algoritmos Interactivos',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Algoritmos Interactivos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AlgorithmCard(
            title: 'Sudoku Solver (Backtracking)',
            description:
                'Resuelve un Sudoku 9x9 usando backtracking. El algoritmo busca la siguiente celda vacía y prueba números del 1 al 9; si en algún punto no hay opciones válidas, retrocede (backtrack).',
            child: SudokuDemo(),
          ),
          SizedBox(height: 16),
          AlgorithmCard(
            title: 'Mochila 0/1 ingenua',
            description:
                'Explora recursivamente todas las combinaciones de tomar/no tomar cada ítem (fuerza bruta). Devuelve el valor máximo sin exceder la capacidad.',
            child: KnapsackDemo(),
          ),
          SizedBox(height: 16),
          AlgorithmCard(
            title: 'Coin Change por enumeración',
            description:
                'Enumera combinaciones de monedas que suman un monto objetivo. Muestra cuántas combinaciones existen y una solución con el menor número de monedas (si hay).',
            child: CoinChangeDemo(),
          ),
          SizedBox(height: 16),
          AlgorithmCard(
            title: 'Closest Pair of Points (par más cercano)',
            description:
                'Dado un conjunto de puntos en el plano, encuentra el par con menor distancia euclidiana. Implementación O(n²) para visualización.',
            child: ClosestPairDemo(),
          ),
          SizedBox(height: 16),
          AlgorithmCard(
            title: 'Hamiltonian path/cycle (backtracking)',
            description:
                'Busca un camino o ciclo Hamiltoniano en un grafo pequeño mediante backtracking, probando vértices y retrocediendo al encontrar bloqueos.',
            child: HamiltonianDemo(),
          ),
        ],
      ),
    );
  }
}

class AlgorithmCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;
  const AlgorithmCard({super.key, required this.title, required this.description, required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

// ======================== SUDOKU ========================
class SudokuDemo extends StatefulWidget {
  const SudokuDemo({super.key});
  @override
  State<SudokuDemo> createState() => _SudokuDemoState();
}

class _SudokuDemoState extends State<SudokuDemo> {
  late List<List<int>> puzzle;
  late List<List<int>> board;
  late List<List<bool>> givens;
  String status = '';

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    // Un puzzle sencillo (0 = vacío)
    puzzle = [
      [5, 3, 0, 0, 7, 0, 0, 0, 0],
      [6, 0, 0, 1, 9, 5, 0, 0, 0],
      [0, 9, 8, 0, 0, 0, 0, 6, 0],
      [8, 0, 0, 0, 6, 0, 0, 0, 3],
      [4, 0, 0, 8, 0, 3, 0, 0, 1],
      [7, 0, 0, 0, 2, 0, 0, 0, 6],
      [0, 6, 0, 0, 0, 0, 2, 8, 0],
      [0, 0, 0, 4, 1, 9, 0, 0, 5],
      [0, 0, 0, 0, 8, 0, 0, 7, 9],
    ];
    board = puzzle.map((r) => List<int>.from(r)).toList();
    givens = List.generate(9, (r) => List.generate(9, (c) => puzzle[r][c] != 0));
    status = '';
    setState(() {});
  }

  bool _isSafe(int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }
    final sr = row - row % 3;
    final sc = col - col % 3;
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (board[sr + r][sc + c] == num) return false;
      }
    }
    return true;
  }

  int attempts = 0;
  bool _solve() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          for (int n = 1; n <= 9; n++) {
            attempts++;
            if (_isSafe(r, c, n)) {
              board[r][c] = n;
              if (_solve()) return true;
              board[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  void _onSolve() {
    attempts = 0;
    final sw = Stopwatch()..start();
    final ok = _solve();
    sw.stop();
    setState(() {
      status = ok
          ? 'Resuelto en ${sw.elapsedMilliseconds} ms · intentos: $attempts'
          : 'No tiene solución';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cambiado: Reducir el tamaño del grid de Sudoku
        SizedBox(
          width: 270, // Tamaño reducido
          height: 270, // Tamaño reducido
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
            itemCount: 81,
            itemBuilder: (context, i) {
              final r = i ~/ 9, c = i % 9;
              final v = board[r][c];
              final isGiven = givens[r][c];
              BorderSide side(double w) => BorderSide(width: w, color: Colors.black26);
              final bLeft = c % 3 == 0 ? side(1.5) : side(0.5);
              final bTop = r % 3 == 0 ? side(1.5) : side(0.5);
              final bRight = (c + 1) % 3 == 0 ? side(1.5) : side(0.5);
              final bBottom = (r + 1) % 3 == 0 ? side(1.5) : side(0.5);
              return Container(
                decoration: BoxDecoration(
                  border: Border(left: bLeft, top: bTop, right: bRight, bottom: bBottom),
                  color: isGiven ? Colors.indigo.withOpacity(0.08) : null,
                ),
                child: Center(
                  // Cambiado: Reducir el tamaño de fuente
                  child: Text(v == 0 ? '' : '$v',
                      style: TextStyle(fontSize: 12, fontWeight: isGiven ? FontWeight.bold : FontWeight.normal)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(status, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          FilledButton(onPressed: _onSolve, child: const Text('Resolver')),
          OutlinedButton(onPressed: _reset, child: const Text('Reiniciar')),
        ]),
      ],
    );
  }
}

// ======================== MOCHILA 0/1 INGENUA ========================
class KnapsackDemo extends StatefulWidget {
  const KnapsackDemo({super.key});
  @override
  State<KnapsackDemo> createState() => _KnapsackDemoState();
}

class _KnapsackDemoState extends State<KnapsackDemo> {
  int n = 5;
  int capacity = 15;
  late List<int> weights;
  late List<int> values;
  String result = '';
  int explored = 0;

  @override
  void initState() {
    super.initState();
    _randomize();
  }

  void _randomize() {
    final rng = Random();
    weights = List<int>.generate(n, (_) => 1 + rng.nextInt(10));
    values = List<int>.generate(n, (_) => 1 + rng.nextInt(20));
    result = '';
    explored = 0;
    setState(() {});
  }

  int _knap(int i, int cap) {
    explored++;
    if (i == n || cap == 0) return 0;
    final without = _knap(i + 1, cap);
    if (weights[i] > cap) return without;
    final withIt = values[i] + _knap(i + 1, cap - weights[i]);
    return max(without, withIt);
  }

  void _solve() {
    explored = 0;
    final sw = Stopwatch()..start();
    final best = _knap(0, capacity);
    sw.stop();
    setState(() {
      result = 'Valor máx: $best · nodos explorados: $explored · ${sw.elapsedMilliseconds} ms';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Ítems:'),
        Expanded(
          child: Slider(
            value: n.toDouble(), min: 3, max: 12, divisions: 9,
            label: '$n',
            onChanged: (v) => setState(() => n = v.round()),
            onChangeEnd: (_) => _randomize(),
          ),
        ),
        const SizedBox(width: 12),
        const Text('Capacidad:'),
        Expanded(
          child: Slider(
            value: capacity.toDouble(), min: 5, max: 40, divisions: 35,
            label: '$capacity',
            onChanged: (v) => setState(() => capacity = v.round()),
          ),
        ),
        FilledButton(onPressed: _solve, child: const Text('Resolver')),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: _randomize, child: const Text('Aleatorio')),
      ]),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(columns: const [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('Peso')),
          DataColumn(label: Text('Valor')),
        ], rows: [
          for (int i = 0; i < n; i++) DataRow(cells: [
            DataCell(Text('${i + 1}')),
            DataCell(Text('${weights[i]}')),
            DataCell(Text('${values[i]}')),
          ])
        ]),
      ),
      const SizedBox(height: 8),
      Text(result, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]);
  }
}

// ======================== COIN CHANGE (ENUMERACIÓN) ========================
class CoinChangeDemo extends StatefulWidget {
  const CoinChangeDemo({super.key});
  @override
  State<CoinChangeDemo> createState() => _CoinChangeDemoState();
}

class _CoinChangeDemoState extends State<CoinChangeDemo> {
  final coinsCtrl = TextEditingController(text: '1,2,5');
  final amountCtrl = TextEditingController(text: '11');
  String info = '';

  @override
  void dispose() {
    coinsCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }

  void _run() {
    final coins = coinsCtrl.text
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .where((v) => v > 0)
        .toSet()
        .toList()
      ..sort();
    final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;
    if (coins.isEmpty || amount <= 0) {
      setState(() => info = 'Ingresa monedas y monto válidos.');
      return;
    }

    int combos = 0;
    int bestCount = 1 << 30;
    List<int> best = [];

    void backtrack(int idx, int rem, List<int> take) {
      if (rem == 0) {
        combos++;
        if (take.length < bestCount) {
          bestCount = take.length;
          best = List<int>.from(take);
        }
        return;
      }
      if (idx == coins.length || rem < 0) return;
      // opción tomar esta moneda
      take.add(coins[idx]);
      backtrack(idx, rem - coins[idx], take);
      take.removeLast();
      // opción pasar a la siguiente moneda
      backtrack(idx + 1, rem, take);
    }

    final sw = Stopwatch()..start();
    backtrack(0, amount, <int>[]);
    sw.stop();

    setState(() {
      info = 'Combinaciones: $combos · Mejor (mín. monedas): ${best.isEmpty ? '—' : best.join('+')} = $amount · ${sw.elapsedMilliseconds} ms';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: TextField(
            controller: coinsCtrl,
            decoration: const InputDecoration(labelText: 'Monedas (ej: 1,2,5)'),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: TextField(
            controller: amountCtrl,
            decoration: const InputDecoration(labelText: 'Monto'),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(onPressed: _run, child: const Text('Enumerar')),
      ]),
      const SizedBox(height: 8),
      Text(info, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]);
  }
}

// ======================== CLOSEST PAIR OF POINTS ========================
class ClosestPairDemo extends StatefulWidget {
  const ClosestPairDemo({super.key});
  @override
  State<ClosestPairDemo> createState() => _ClosestPairDemoState();
}

class _ClosestPairDemoState extends State<ClosestPairDemo> {
  int n = 25;
  late List<Offset> points;
  String result = '';

  @override
  void initState() {
    super.initState();
    _randomize();
  }

  void _randomize() {
    final rng = Random();
    points = List<Offset>.generate(n, (_) => Offset(rng.nextDouble(), rng.nextDouble()));
    result = '';
    setState(() {});
  }

  double _dist(Offset a, Offset b) {
    final dx = a.dx - b.dx, dy = a.dy - b.dy;
    return sqrt(dx * dx + dy * dy);
  }

  (int, int, double) _closestPair() {
    double best = double.infinity;
    int iBest = -1, jBest = -1;
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final d = _dist(points[i], points[j]);
        if (d < best) {
          best = d; iBest = i; jBest = j;
        }
      }
    }
    return (iBest, jBest, best);
  }

  void _solve() {
    final sw = Stopwatch()..start();
    final (i, j, d) = _closestPair();
    sw.stop();
    setState(() {
      result = 'Par más cercano: #$i – #$j · distancia: ${d.toStringAsFixed(4)} · ${sw.elapsedMilliseconds} ms';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        const Text('Puntos:'),
        Expanded(
          child: Slider(
            value: n.toDouble(), min: 5, max: 200, divisions: 39,
            label: '$n',
            onChanged: (v) => setState(() => n = v.round()),
            onChangeEnd: (_) => _randomize(),
          ),
        ),
        FilledButton(onPressed: _solve, child: const Text('Calcular')),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: _randomize, child: const Text('Aleatorio')),
      ]),
      const SizedBox(height: 8),
      SizedBox(
        width: 320, height: 320,
        child: CustomPaint(
          painter: _PointsPainter(points),
          child: const SizedBox.expand(),
        ),
      ),
      const SizedBox(height: 8),
      Text(result, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]);
  }
}

class _PointsPainter extends CustomPainter {
  final List<Offset> points; _PointsPainter(this.points);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < points.length; i++) {
      final o = Offset(points[i].dx * size.width, points[i].dy * size.height);
      canvas.drawCircle(o, 3, p);
    }
  }
  @override
  bool shouldRepaint(covariant _PointsPainter oldDelegate) => oldDelegate.points != points;
}

// ======================== HAMILTONIAN PATH/CYCLE ========================
class HamiltonianDemo extends StatefulWidget {
  const HamiltonianDemo({super.key});
  @override
  State<HamiltonianDemo> createState() => _HamiltonianDemoState();
}

class _HamiltonianDemoState extends State<HamiltonianDemo> {
  // Grafo pequeño (6 nodos) como lista de adyacencia
  final List<List<int>> g = [
    [1, 2, 5],   // 0
    [0, 2, 3],   // 1
    [0, 1, 3, 4],// 2
    [1, 2, 4],   // 3
    [2, 3, 5],   // 4
    [0, 4],      // 5
  ];
  bool wantCycle = false;
  String result = '';

  bool _validNext(int v, List<int> path, Set<int> used) {
    if (used.contains(v)) return false;
    final u = path.last;
    return g[u].contains(v);
  }

  bool _hamiltonian({required bool cycle}) {
    final n = g.length;
    final path = <int>[0];
    final used = <int>{0};

    bool backtrack() {
      if (path.length == n) {
        if (!cycle) return true;
        return g[path.last].contains(path.first);
      }
      for (int v = 0; v < n; v++) {
        if (_validNext(v, path, used)) {
          path.add(v); used.add(v);
          if (backtrack()) {
            result = cycle ? 'Ciclo: ${path.join(' → ')} → ${path.first}' : 'Camino: ${path.join(' → ')}';
            return true;
          }
          used.remove(v); path.removeLast();
        }
      }
      return false;
    }

    final sw = Stopwatch()..start();
    final ok = backtrack();
    sw.stop();
    setState(() {
      result = ok ? '$result · ${sw.elapsedMilliseconds} ms' : 'No se encontró solución · ${sw.elapsedMilliseconds} ms';
    });
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Switch(value: wantCycle, onChanged: (v) => setState(() => wantCycle = v)),
        const Text('Buscar ciclo (ON) o camino (OFF)'),
        const Spacer(),
        FilledButton(
          onPressed: () => _hamiltonian(cycle: wantCycle),
          child: const Text('Buscar'),
        ),
      ]),
      const SizedBox(height: 8),
      Text(result, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Grafo (lista de adyacencia): ${g.asMap().entries.map((e) => "${e.key}: ${e.value}").join('  |  ')}'),
    ]);
  }
}