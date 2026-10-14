# Guía paso a paso — Publicar Voley Score en Google Play

Desarrollador: **Crea2app**  ·  Paquete: `com.voleyscore.scoreboard`

---

## Paso 0. Requisitos previos

1. Una **cuenta de Google Play Console** (https://play.google.com/console).
   - Cuota única de **25 USD**.
   - Si es una cuenta **personal nueva** (creada después de nov-2023), Google exige
     **prueba cerrada con ≥20 testers durante ≥14 días** antes de poder publicar en producción.
   - Si es cuenta de **organización/empresa**, no aplica esa prueba.
2. Tener a mano el **AAB firmado**: `build/app/outputs/bundle/release/app-release.aab`.
3. **GUARDA el keystore** `android/release-key.jks` y `android/key.properties` en un lugar
   seguro y con copia de seguridad. Si los pierdes, no podrás actualizar la app.

---

## Paso 1. Crear la app en Play Console

1. Play Console → **Crear app**.
2. Nombre de la app: **Voley Score**.
3. Idioma predeterminado: **Español (España) – es-ES**.
4. Tipo: **Aplicación**. Gratis.
5. Acepta las declaraciones (políticas de desarrollador, leyes de exportación de EE. UU.).

---

## Paso 2. Completar "Configuración de la app" (App content)

Rellena cada apartado del menú lateral:

| Apartado | Qué poner |
|---|---|
| Política de privacidad | `https://manuelpq.github.io/Crea2app/voleyscore.html` |
| Acceso a la app | Todas las funciones disponibles sin restricciones (no hay login) |
| Anuncios | **No contiene anuncios** |
| Clasificación de contenido | Rellenar cuestionario (todo "No") → Apto para todos |
| Público objetivo | 13+ (o Todos; sin contenido sensible) |
| Seguridad de los datos | Declarar que **no se recopilan datos** |
| Aplicación gubernamental | No |
| Financiación / Noticias | No |

---

## Paso 3. Ficha de Play Store (Store listing)

1. **Nombre** (30): `Voley Score`
2. **Descripción corta** (80): copia de `play_listing_es.md`.
3. **Descripción larga** (4000): copia de `play_listing_es.md`.
4. **Icono**: sube `store/play_icon_512.png`.
5. **Gráfico destacado**: sube `store/play_feature_1024x500.png`.
6. **Capturas de teléfono**: sube al menos 2 (recomendado las 6 de `store/`).
7. **Categoría**: Deportes.  **Etiquetas**: Vóley playa / Marcador.
8. **Datos de contacto**: crear2app@gmail.com, sitio web del repo.

---

## Paso 4. Subir el AAB

1. Menú → **Prueba** → **Prueba cerrada** (o **Producción** si la cuenta no lo exige).
2. Crea una pista (track) y sube `app-release.aab`.
3. Escribe las **notas de la versión** (release notes):
   ```
   Primera versión de Voley Score.
   • Marcador de vóley playa con puntos y sets
   • Cambio de pista automático
   • Historial de partidos
   • Colores de equipo personalizables
   ```
4. Si es cuenta personal nueva: añade ≥20 testers (correos de Gmail), publica la prueba
   cerrada y espera 14 días con actividad antes de pedir producción.

---

## Paso 5. Revisión y publicación

1. Revisa que no haya avisos en "Panel de control" (todos los check en verde).
2. Envía a revisión. Google suele tardar de **unas horas a 3-7 días**.
3. Una vez aprobada, la app estará disponible en Play Store.

---

## Paso 6. Actualizaciones futuras

Para cada nueva versión:
1. Sube el número de versión en `pubspec.yaml`: `version: 1.0.1+2` (el `+2` es el versionCode,
   **siempre debe ser mayor** que el anterior).
2. Recompila el AAB y súbelo a Play Console.
3. Publica.

---

## Apple App Store (más adelante)

- Requiere **un Mac con Xcode** para compilar (no es posible generar el build iOS en este entorno Linux).
- Cuenta de **Apple Developer Program**: 99 USD/año.
- Pasos: crear App ID, configurar en App Store Connect, subir el build con Xcode/Transporter,
  capturas 6.7"/5.5", política de privacidad, revisión de Apple.
- Se puede reutilizar toda la lógica Flutter; solo hay que abrir el proyecto en un Mac y
  ejecutar `flutter build ipa`.
