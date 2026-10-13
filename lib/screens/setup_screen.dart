import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../providers/scoreboard_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncing_ball.dart';

/// Pantalla previa: se elige tipo de partido, puntos, cambios y nombres.
///
/// Pensada para **entrar completa** en horizontal (poco alto disponible):
/// - Columna izquierda: pelota animada + título + botón EMPEZAR (siempre visible).
/// - Columna derecha: tarjeta blanca con toda la configuración.
/// Se adapta a la altura de la pantalla y, solo como red de seguridad,
/// permite desplazar el contenido mostrando una pista ("más abajo").
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, this.onStart});

  final VoidCallback? onStart;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late GameSetup _setup;
  late TextEditingController _a;
  late TextEditingController _b;
  final ScrollController _scroll = ScrollController();
  bool _puedeDesplazar = false;

  @override
  void initState() {
    super.initState();
    final score = context.read<ScoreboardProvider>();
    _setup = score.settings.defaultSetup;
    _a = TextEditingController(text: _setup.teamA);
    _b = TextEditingController(text: _setup.teamB);
    _scroll.addListener(_actualizarPista);
    WidgetsBinding.instance.addPostFrameCallback((_) => _actualizarPista());
  }

  void _actualizarPista() {
    if (!_scroll.hasClients) return;
    final restante = _scroll.position.maxScrollExtent - _scroll.position.pixels;
    final puede = restante > 4;
    if (puede != _puedeDesplazar) {
      setState(() => _puedeDesplazar = puede);
    }
  }

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _start() {
    final score = context.read<ScoreboardProvider>();
    final s = _setup.copyWith(
      teamA: _a.text.trim().isEmpty ? 'Equipo A' : _a.text.trim(),
      teamB: _b.text.trim().isEmpty ? 'Equipo B' : _b.text.trim(),
    );
    score.startMatch(s);
    widget.onStart?.call();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: dark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.darkBg, Color(0xFF1E2A38)],
                )
              : AppGradients.sunset,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              final h = c.maxHeight;
              final compacto = h < 340;
              final medio = h < 420;
              final pad = compacto ? 8.0 : 12.0;
              return Padding(
                padding: EdgeInsets.all(pad),
                child: Row(
                  children: [
                    Expanded(
                      flex: 30,
                      child: _columnaIzquierda(
                        compacto: compacto,
                        medio: medio,
                        dark: dark,
                      ),
                    ),
                    SizedBox(width: compacto ? 6 : 10),
                    Expanded(
                      flex: 70,
                      child: _tarjetaConfiguracion(compacto: compacto),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------- Columna izquierda ----------------
  Widget _columnaIzquierda({
    required bool compacto,
    required bool medio,
    required bool dark,
  }) {
    final ballSize = compacto ? 62.0 : (medio ? 88.0 : 108.0);
    final titleSize = compacto ? 24.0 : (medio ? 30.0 : 36.0);
    final btnHeight = compacto ? 44.0 : 52.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BouncingBall(size: ballSize),
        SizedBox(height: compacto ? 6 : 12),
        Text(
          'Nuevo partido',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleSize,
            height: 1,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        if (!compacto) ...[
          const SizedBox(height: 4),
          Text(
            'Configura y pulsa EMPEZAR',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: medio ? 12 : 14,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
        SizedBox(height: compacto ? 10 : 14),
        SizedBox(
          width: double.infinity,
          height: btnHeight,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.sunsetDeep,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: _start,
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              'EMPEZAR',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Tarjeta derecha ----------------
  Widget _tarjetaConfiguracion({required bool compacto}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compacto ? 14 : 20,
              vertical: compacto ? 10 : 14,
            ),
            child: Scrollbar(
              controller: _scroll,
              child: SingleChildScrollView(
                controller: _scroll,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fila 1: nombres + VS
                    Row(
                      children: [
                        Expanded(child: _teamField(_a, 'Equipo A')),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Expanded(child: _teamField(_b, 'Equipo B')),
                      ],
                    ),
                    SizedBox(height: compacto ? 8 : 12),
                    _divider(),
                    _configRow(
                      'Puntos para finalizar',
                      _setup.targetPoints,
                      5,
                      30,
                      (v) => setState(
                        () => _setup = _setup.copyWith(targetPoints: v),
                      ),
                    ),
                    _divider(),
                    _configRow(
                      'Cambio de pista cada',
                      _setup.switchEvery,
                      0,
                      15,
                      (v) => setState(
                        () => _setup = _setup.copyWith(switchEvery: v),
                      ),
                      suffix: _setup.switchEvery == 0
                          ? 'sin cambios'
                          : 'puntos',
                    ),
                    _divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Tipo de partido',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SegmentedButton<MatchType>(
                            showSelectedIcon: false,
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            segments: const [
                              ButtonSegment(
                                value: MatchType.single,
                                label: Text('Único'),
                              ),
                              ButtonSegment(
                                value: MatchType.bestOf3,
                                label: Text('Mejor de 3'),
                              ),
                            ],
                            selected: {_setup.type},
                            onSelectionChanged: (v) => setState(
                              () => _setup = _setup.copyWith(type: v.first),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_setup.type == MatchType.bestOf3) ...[
                      _divider(),
                      _configRow(
                        'Set decisivo',
                        _setup.decidingPoints,
                        5,
                        21,
                        (v) => setState(
                          () => _setup = _setup.copyWith(decidingPoints: v),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Pista de desplazamiento (solo si hiciera falta)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _puedeDesplazar ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (dark ? AppColors.darkSurface : Colors.white)
                            .withValues(alpha: 0),
                        (dark ? AppColors.darkSurface : Colors.white),
                      ],
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.keyboard_arrow_down, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Desliza para ver más',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _divider() => Divider(
    height: 14,
    thickness: 1,
    color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
  );

  /// Fila de ajuste: título a la izquierda y control numérico a la derecha.
  Widget _configRow(
    String title,
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged, {
    String suffix = 'puntos',
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        _circleBtn(
          Icons.remove,
          value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 58,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              if (suffix.isNotEmpty)
                Text(
                  suffix,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
            ],
          ),
        ),
        _circleBtn(Icons.add, value < max ? () => onChanged(value + 1) : null),
      ],
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback? onTap) {
    return IconButton.filledTonal(
      onPressed: onTap,
      iconSize: 20,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      visualDensity: VisualDensity.compact,
      icon: Icon(icon),
    );
  }
}
