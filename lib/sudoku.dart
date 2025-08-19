// sudoku.dart
// Generación de puzzle SIEMPRE resoluble + dos resolutores:
// 1) Fuerza bruta (naive)
// 2) Backtracking optimizado (MRV: Minimum Remaining Values)

import 'dart:math';

typedef Board = List<List<int>>;

/// Clona una matriz 9x9
Board cloneBoard(Board b) =>
    List.generate(9, (r) => List<int>.from(b[r]), growable: false);

/// ¿Es válido poner `num` en (row, col)?
bool isSafe(Board board, int row, int col, int num) {
  for (int i = 0; i < 9; i++) {
    if (board[row][i] == num) return false; // fila
    if (board[i][col] == num) return false; // columna
  }
  final sr = row - row % 3;
  final sc = col - col % 3;
  for (int r = 0; r < 3; r++) {
    for (int c = 0; c < 3; c++) {
      if (board[sr + r][sc + c] == num) return false; // subcuadro
    }
  }
  return true;
}

/// Candidatos válidos para (row, col)
List<int> candidates(Board board, int row, int col) {
  if (board[row][col] != 0) return const [];
  final used = List<bool>.filled(10, false);

  for (int i = 0; i < 9; i++) {
    used[board[row][i]] = true;
    used[board[i][col]] = true;
  }
  final sr = row - row % 3;
  final sc = col - col % 3;
  for (int r = 0; r < 3; r++) {
    for (int c = 0; c < 3; c++) {
      used[board[sr + r][sc + c]] = true;
    }
  }
  final out = <int>[];
  for (int n = 1; n <= 9; n++) {
    if (!used[n]) out.add(n);
  }
  return out;
}

/// --------- GENERACIÓN DE TABLERO COMPLETO VÁLIDO (sin backtracking) ---------
/// Usamos un patrón estándar + barajado de filas/columnas/bandas y dígitos.
/// Esto crea una solución completa válida muy rápido.
Board generateSolvedGrid([Random? rng]) {
  rng ??= Random();
  const base = 3;
  const side = base * base;

  int pattern(int r, int c) => (base * (r % base) + r ~/ base + c) % side;

  List<T> shuffled<T>(List<T> items) {
    final list = List<T>.from(items);
    list.shuffle(rng);
    return list;
  }

  final rBase = List<int>.generate(base, (i) => i);
  final rows = [
    for (final g in shuffled(rBase))
      for (final r in shuffled(rBase)) g * base + r
  ];
  final cols = [
    for (final g in shuffled(rBase))
      for (final c in shuffled(rBase)) g * base + c
  ];
  final nums = shuffled(List<int>.generate(side, (i) => i + 1));

  final grid = List.generate(
    side,
    (r) => List.generate(
      side,
      (c) => nums[pattern(rows[r], cols[c])],
      growable: false,
    ),
    growable: false,
  );
  return grid;
}

/// A partir de una solución completa, quitamos celdas para formar el puzzle.
/// Siempre será resoluble (al menos por la solución original). Unicidad no garantizada.
Board makePuzzleFromSolution(Board solution, int clues, [Random? rng]) {
  rng ??= Random();
  clues = clues.clamp(17, 81); // 17 es el mínimo clásico
  final board = cloneBoard(solution);
  final positions = List<int>.generate(81, (i) => i)..shuffle(rng);
  final toRemove = 81 - clues;

  for (int i = 0; i < toRemove; i++) {
    final p = positions[i];
    final r = p ~/ 9, c = p % 9;
    board[r][c] = 0;
  }
  return board;
}

/// --------- SOLVER 1: Fuerza bruta (naive) ---------
/// Backtracking básico: recorre celda vacía en orden y prueba 1..9 con isSafe.
bool solveNaive(Board board) {
  for (int row = 0; row < 9; row++) {
    for (int col = 0; col < 9; col++) {
      if (board[row][col] == 0) {
        for (int num = 1; num <= 9; num++) {
          if (isSafe(board, row, col, num)) {
            board[row][col] = num;
            if (solveNaive(board)) return true;
            board[row][col] = 0; // backtrack
          }
        }
        return false; // ninguna opción viable aquí
      }
    }
  }
  return true; // sin ceros => resuelto
}

/// --------- SOLVER 2: Backtracking optimizado (MRV) ---------
/// Elige siempre la celda con menos candidatos (poda + forward-checking ligero).
bool solveMRV(Board board) {
  int? selRow;
  int? selCol;
  List<int>? selCand;

  for (int r = 0; r < 9; r++) {
    for (int c = 0; c < 9; c++) {
      if (board[r][c] == 0) {
        final cand = candidates(board, r, c);
        if (cand.isEmpty) return false; // inconsistencia
        if (selCand == null || cand.length < selCand.length) {
          selCand = cand;
          selRow = r;
          selCol = c;
          if (selCand.length == 1) break; // ya es mínimo posible
        }
      }
    }
  }

  if (selCand == null) return true; // no hay vacías => resuelto

  for (final n in selCand) {
    board[selRow!][selCol!] = n;
    if (solveMRV(board)) return true;
    board[selRow][selCol] = 0; // backtrack
  }
  return false;
}
