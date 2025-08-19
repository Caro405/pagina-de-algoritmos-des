import 'dart:math';
import 'package:flutter/material.dart';
import 'sudoku.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const SudokuPage(),
    );
  }
}

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});
  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  final _rng = Random();

  late Board _solution;       // solución completa válida
  late Board _puzzle;         // puzzle con ceros (lo que se muestra al inicio)
  late Board _board;          // tablero actual (se va llenando al resolver)
  late List<List<bool>> _givens; // máscara de pistas fijas (para estilo)

  String _status = "";        // texto de tiempo/resultado
  int _clues = 32;            // cantidad de pistas del puzzle

  @override
  void initState() {
    super.initState();
    _newPuzzle();
  }

  void _newPuzzle() {
    _solution = generateSolvedGrid(_rng);
    _puzzle = makePuzzleFromSolution(_solution, _clues, _rng);
    _board = cloneBoard(_puzzle);
    _givens = List.generate(
      9,
      (r) => List.generate(9, (c) => _puzzle[r][c] != 0),
    );
    _status = "";
    setState(() {});
  }

  void _resetToPuzzle() {
    _board = cloneBoard(_puzzle);
    _status = "";
    setState(() {});
  }

  void _solveBrute() {
    // Usamos copia del puzzle para no alterar el original
    final b = cloneBoard(_puzzle);
    final sw = Stopwatch()..start();
    final ok = solveNaive(b);
    sw.stop();
    if (ok) {
      _board = b;
      _status = "Fuerza bruta (naive): ${sw.elapsedMilliseconds} ms ✓";
    } else {
      _status = "Fuerza bruta (naive): sin solución (¿puzzle inconsistente?)";
    }
    setState(() {});
  }

  void _solveBacktracking() {
    final b = cloneBoard(_puzzle);
    final sw = Stopwatch()..start();
    final ok = solveMRV(b);
    sw.stop();
    if (ok) {
      _board = b;
      _status = "Backtracking (MRV): ${sw.elapsedMilliseconds} ms ✓";
    } else {
      _status = "Backtracking (MRV): sin solución (¿puzzle inconsistente?)";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cellTextStyleGiven = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    final cellTextStyleFilled = const TextStyle(fontSize: 18, fontWeight: FontWeight.normal);

    return Scaffold(
      appBar: AppBar(title: const Text("Sudoku – Comparar métodos")),
      body: Column(
        children: [
          // Controles arriba (opcional: selector de pistas)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text("Pistas:"),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _clues,
                  items: const [24, 28, 32, 36, 40, 48, 56, 64, 72]
                      .map((v) => DropdownMenuItem(value: v, child: Text("$v")))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _clues = v);
                    _newPuzzle();
                  },
                ),
                const Spacer(),
                Text(_status, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // Grilla 9x9
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final r = index ~/ 9;
                final c = index % 9;
                final v = _board[r][c];
                final isGiven = _givens[r][c];

                // Bordes más gruesos para subcuadros 3x3
                BorderSide side(double w) => BorderSide(width: w, color: Colors.black26);
                final bLeft  = c % 3 == 0 ? side(1.5) : side(0.5);
                final bTop   = r % 3 == 0 ? side(1.5) : side(0.5);
                final bRight = (c + 1) % 3 == 0 ? side(1.5) : side(0.5);
                final bBottom= (r + 1) % 3 == 0 ? side(1.5) : side(0.5);

                return Container(
                  decoration: BoxDecoration(
                    border: Border(left: bLeft, top: bTop, right: bRight, bottom: bBottom),
                    color: isGiven ? Colors.blue.withOpacity(0.07) : null,
                  ),
                  child: Center(
                    child: Text(
                      v == 0 ? "" : "$v",
                      style: isGiven ? cellTextStyleGiven : cellTextStyleFilled,
                    ),
                  ),
                );
              },
            ),
          ),

          // Botones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  onPressed: _solveBrute,
                  child: const Text("Resolver (Fuerza Bruta)"),
                ),
                FilledButton.tonal(
                  onPressed: _solveBacktracking,
                  child: const Text("Resolver (Backtracking)"),
                ),
                OutlinedButton(
                  onPressed: _newPuzzle,
                  child: const Text("Reiniciar"),
                ),
                TextButton(
                  onPressed: _resetToPuzzle,
                  child: const Text("Restaurar puzzle"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
