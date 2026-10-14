import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Política de privacidad de Voley Score.
///
/// Nota: Google Play exige una URL pública de política de privacidad en la
/// ficha de la tienda. Aquí se muestra el mismo texto dentro de la app para
/// que el usuario pueda consultarlo sin conexión.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = Theme.of(context).textTheme.bodySmall?.color;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Política de privacidad',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Row(
            children: [
              const Icon(
                Icons.privacy_tip_outlined,
                color: AppColors.sunsetDeep,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Voley Score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Última actualización: octubre de 2026',
            style: TextStyle(fontSize: 12, color: sub),
          ),
          const SizedBox(height: 18),
          const _Seccion(
            titulo: '1. Información que recopilamos',
            texto:
                'Voley Score NO recopila, transmite ni comparte ningún dato '
                'personal. La aplicación funciona totalmente sin conexión y no '
                'solicita permisos de acceso a tu ubicación, contactos, cámara, '
                'micrófono ni almacenamiento externo.',
          ),
          const _Seccion(
            titulo: '2. Datos guardados en tu dispositivo',
            texto:
                'Los nombres de los equipos, los resultados de los partidos, el '
                'historial, la configuración y los colores elegidos se guardan '
                'ÚNICAMENTE en tu propio teléfono (almacenamiento local). Estos '
                'datos nunca salen de tu dispositivo y puedes borrarlos en '
                'cualquier momento desinstalando la aplicación o vaciando la '
                'papelera del historial.',
          ),
          const _Seccion(
            titulo: '3. Publicidad y servicios de terceros',
            texto:
                'La aplicación NO contiene publicidad y NO utiliza servicios de '
                'análisis ni de rastreo de terceros.',
          ),
          const _Seccion(
            titulo: '4. Menores de edad',
            texto:
                'La aplicación es apta para todos los públicos y no recopila '
                'información de ningún usuario, incluidos los menores.',
          ),
          const _Seccion(
            titulo: '5. Permisos',
            texto:
                'La app únicamente puede solicitar el permiso de vibración para '
                'dar respuesta táctil al marcar puntos. No se usa ningún otro '
                'permiso.',
          ),
          const _Seccion(
            titulo: '6. Cambios en esta política',
            texto:
                'Si en el futuro se modifica esta política (por ejemplo, al '
                'añadir nuevas funciones), se actualizará esta misma pantalla '
                'con la fecha de la última revisión.',
          ),
          const _Seccion(
            titulo: '7. Contacto',
            texto:
                'Si tienes cualquier duda sobre esta política de privacidad, '
                'puedes escribirnos a: crear2app@gmail.com',
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.sunsetOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: AppColors.sunsetDeep, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Resumen: no se recopila ningún dato personal. Todo se '
                    'guarda solo en tu dispositivo.',
                    style: TextStyle(fontSize: 13, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.texto});

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final sub = Theme.of(context).textTheme.bodySmall?.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(texto, style: TextStyle(fontSize: 14, height: 1.45, color: sub)),
        ],
      ),
    );
  }
}
