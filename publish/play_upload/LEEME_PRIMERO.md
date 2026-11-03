# CÓMO PUBLICAR VOLEY SCORE EN GOOGLE PLAY

Guía paso a paso para **Crea2app**. Sigue el orden y no tendrás problemas.

> Tiempo total estimado la primera vez: **2-3 horas** de trabajo tuyo
> + **7-14 días de espera** obligatoria de Google (prueba cerrada).

---

## ANTES DE EMPEZAR: lo que necesitas a mano

| Cosa | Dónde está |
|---|---|
| Archivo `.aab` (el que se sube a Play) | carpeta `app/` → `VoleyScore-1.0.0-release.aab` |
| Icono 512×512 | `graficos/icono_512.png` |
| Gráfico destacado 1024×500 | `graficos/grafico_destacado_1024x500.png` |
| 6 capturas de pantalla | `graficos/captura_1...6.png` |
| Textos para copiar y pegar | carpeta `textos/` |
| Cuenta de Google | la tuya |
| 25 $ (pago único, una sola vez en la vida) | tarjeta |

> El APK de `app/` **no** se sube a Play. Sirve solo para que tú pruebes
> la app en tu móvil. A Play se sube únicamente el `.aab`.

---

# FASE 1 · Crear la cuenta de desarrollador (20 min)

**1.1** Entra en <https://play.google.com/console> con tu cuenta de Google
(preferible una cuenta nueva solo para esto, por ejemplo la de `crear2app@gmail.com`).

**1.2** Acepta el Acuerdo de Distribución para Desarrolladores.

**1.3** Paga los **25 $** (pago único, no es anual).

**1.4** Rellena tus datos de desarrollador:

- **Nombre público del desarrollador:** `Crea2app`
- **Correo electrónico:** `crear2app@gmail.com`
- **Sitio web:** `https://manuelpq.github.io/Crea2app/index.html`
- **Dirección:** tu dirección real (no se publica, es solo para Google)

**1.5** Google tarda **entre 1 y 3 días** en verificar tu identidad.
Hasta que no te avisen por correo, no podrás publicar. Tenlo en cuenta.

---

# FASE 2 · Crear la app en Play Console (10 min)

**2.1** En Play Console pulsa **"Crear app"**.

**2.2** Rellena:

| Campo | Qué poner |
|---|---|
| Nombre de la app | `Voley Score` |
| Idioma predeterminado | Español (España) |
| Tipo de app | Aplicación |
| Gratuita o de pago | **Gratuita** |
| Declaraciones | Marca las dos casillas |

**2.3** Pulsa **"Crear app"**.

---

# FASE 3 · Rellenar el panel "Configuración de la app" (40 min)

En el menú de la izquierda verás una lista de tareas. Ve una por una.
**No hace falta completarlas en orden**, pero sí todas antes de publicar.

### 3.1 · Acceso a la app
Como la app **no tiene login**, elige:
> "Todas las funciones de mi app están disponibles sin restricciones"

### 3.2 · Anuncios
> "Mi app **no** contiene anuncios" ✔

### 3.3 · Clasificación de contenido
Rellena el cuestionario con las respuestas de
`textos/7_respuestas_cuestionarios.txt`.
Resultado que obtendrás: **Apto para todos (PEGI 3)**.

### 3.4 · Público objetivo y contenido
- Grupo de edad: **18 años o más** (marca solo ese)
  > Aunque la app sea apta para todos, si marcas "menores" Google te
  > obliga a cumplir la política de Familias, que es mucho más estricta.
  > Marcando 18+ te ahorras ese trámite y la app sigue siendo descargable
  > por cualquiera.
- ¿La app atrae a niños? → **No**

### 3.5 · Seguridad de los datos
Responde con `textos/7_respuestas_cuestionarios.txt`:
- ¿Recopila o comparte datos? → **NO**
- Anuncios → **No**
- Con eso terminas la sección.

### 3.6 · App gubernamental / Finanzas / Salud
Las tres → **No** (son declaraciones; tu app no es ninguna de esas)

### 3.7 · Política de privacidad
Pega la URL:
```
https://manuelpq.github.io/Crea2app/voleyscore.html
```
(Ya está online y funcionando, la he comprobado.)

---

# FASE 4 · Ficha de la tienda (30 min)

Menú izquierdo → **"Presencia en Play Store" → "Ficha de la tienda principal"**

Ve a la pestaña **"Español (es-ES)"** y rellena copiando de la carpeta `textos/`:

| Campo | Archivo a copiar |
|---|---|
| Nombre de la app | `textos/1_nombre_app.txt` |
| Descripción corta | `textos/2_descripcion_corta.txt` |
| Descripción completa | `textos/3_descripcion_larga.txt` |

**Gráficos** (botón "Añadir" en cada uno):

| Recurso | Archivo |
|---|---|
| Icono de la app | `graficos/icono_512.png` |
| Gráfico destacado | `graficos/grafico_destacado_1024x500.png` |
| Capturas de teléfono | las 6 de `graficos/captura_*.png`, **en este orden**: |

1. `captura_1_configuracion.png`
2. `captura_2_marcador.png`
3. `captura_3_fin_partido.png`
4. `captura_4_historial.png`
5. `captura_5_ajustes.png`
6. `captura_6_privacidad.png`

**Categoría y contacto** (misma pantalla, más abajo):

- Categoría de la app: **Deportes**
- Correo electrónico: `crear2app@gmail.com`
- Sitio web: `https://manuelpq.github.io/Crea2app/index.html`

> Las capturas 4, 5 y 6 son verticales (móvil) y las 1, 2 y 3
> horizontales. Es correcto: Play acepta ambas.

---

# FASE 5 · Subir el archivo .aab (10 min)

**5.1** Menú izquierdo → **"Probar y publicar" → "Prueba cerrada"**.

> ⚠️ **Importante:** si tu cuenta es nueva y personal, Google te **obliga**
> a pasar por una prueba cerrada con **al menos 12 testers** durante
> **14 días seguidos** antes de poder publicar en producción.
> No es un error tuyo: es una norma de Google desde 2023.

**5.2** Pestaña **"Testers"** → **"Crear lista de correo"**.
Añade **12 correos de Gmail** de personas que puedan probarla
(familia, amigos, compañeros). Guárdalos.

**5.3** Pestaña **"Versiones"** → **"Crear nueva versión"**.

**5.4** Si te pregunta por la firma de apps, elige:
> **"Usar la clave de firma de Play"** (recomendado, es lo más sencillo)

**5.5** Sube el archivo:
```
app/VoleyScore-1.0.0-release.aab
```
Google lo analizará unos segundos.

**5.6** En **"Notas de la versión"** pega `textos/4_notas_de_la_version.txt`.

**5.7** Pulsa **"Siguiente"** → **"Guardar"** → **"Revisar versión"**
→ **"Iniciar implementación en prueba cerrada"**.

**5.8** Copia el enlace de la prueba y mándalo a tus 12 testers.
Ellos deben:
1. Abrir el enlace y aceptar ser testers.
2. Instalar la app desde Play.
3. **Abrirla y usarla** (con abrirla basta, pero mejor que jueguen un partido).

> 🔴 **MUY IMPORTANTE:** Los 12 testers tienen que estar dados de alta
> **14 días completos**. Si se dan de baja, el contador se reinicia.
> Pon una alarma en el calendario para el día 15.

---

# FASE 6 · Publicar en producción (día 15)

Cuando hayan pasado los 14 días:

**6.1** Menú → **"Probar y publicar" → "Producción"** → **"Crear nueva versión"**.

**6.2** Sube **otra vez** el mismo `.aab` (o usa "Añadir desde biblioteca"
y selecciona la versión que ya subiste).

**6.3** Notas de la versión: las mismas.

**6.4** **"Revisar versión"** → **"Iniciar implementación en producción"**.

**6.5** Google revisa la app. Suele tardar **de 1 a 7 días**.
Te llega un correo cuando esté aprobada y publicada.

---

# DESPUÉS: qué hacer si Google rechaza algo

Los motivos más habituales y cómo resolverlos:

| Aviso de Google | Qué significa | Solución |
|---|---|---|
| "Política de privacidad no válida" | La URL no carga | Comprueba que `https://manuelpq.github.io/Crea2app/voleyscore.html` abre en el móvil |
| "Faltan capturas" | Menos de 2 capturas | Sube las 6 otra vez |
| "Icono no válido" | Formato o tamaño | Usa exactamente `graficos/icono_512.png` |
| "Seguridad de los datos incompleta" | No rellenaste esa sección | Ve a Configuración de la app → Seguridad de los datos |
| "La app no está disponible para testers" | Los 14 días no han pasado | Espera, no hay atajo |

---

# ARCHIVOS DE ESTE PAQUETE

```
VoleyScore_Play/
├── LEEME_PRIMERO.md            ← este tutorial
├── app/
│   ├── VoleyScore-1.0.0-release.aab   ← ESTE se sube a Play
│   └── VoleyScore-1.0.0-release.apk   ← este es para tu móvil
├── graficos/
│   ├── icono_512.png
│   ├── icono_1024.png                  (por si te lo piden)
│   ├── grafico_destacado_1024x500.png
│   └── captura_1...6.png
└── textos/
    ├── 1_nombre_app.txt
    ├── 2_descripcion_corta.txt
    ├── 3_descripcion_larga.txt
    ├── 4_notas_de_la_version.txt
    ├── 5_politica_privacidad_url.txt
    ├── 6_datos_de_contacto.txt
    └── 7_respuestas_cuestionarios.txt
```

---

# DATOS TÉCNICOS (por si los necesitas)

| Dato | Valor |
|---|---|
| Nombre del paquete | `com.voleyscore.scoreboard` |
| Versión | 1.0.0 |
| versionCode | 1 |
| Tamaño del AAB | 42,8 MB |
| Tamaño instalado aprox. | 60 MB |
| Firma | SHA-256 `E0:0B:FB:C3:...:48:CF` |
| Permisos de Android | **ninguno** |
| Requiere Android | 5.0 o superior |
| Idiomas | Español |
| Desarrollador | Crea2app |
| Soporte | crear2app@gmail.com |

> 🔑 **Guarda tu archivo `release-key.jks` y su contraseña en un sitio seguro
> y para siempre.** Sin él no podrás actualizar la app en el futuro.
> Ya lo tienes guardado en `firma_android.zip` (te lo pasé antes).

---

# ORDEN RECOMENDADO (resumen express)

```
Día 1   → Cuenta de desarrollador (25 $) + crear app + rellenar todo
          el panel de configuración + subir ficha + subir AAB a prueba cerrada
Día 1   → Reclutar 12 testers
Día 2-14 → Esperar (los testers deben tener la app instalada)
Día 15  → Pasar a producción
Día 16-22 → Google revisa y publica
```

¡Ya está! Con esto la app queda publicada y descargable por cualquiera.
