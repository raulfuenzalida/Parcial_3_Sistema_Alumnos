# Registro de seguridad · Sistema Alumnos

Estudiante: Raúl Fuenzalida   Repositorio: https://github.com/raulfuenzalida/Parcial_3_Sistema_Alumnos.git   Fecha: 27/11/2026

Completa este registro a medida que avanzas. Cada fila debe poder seguirse hasta un **build de Jenkins**
y un **commit** (usa el identificador `VULN-xx` en el mensaje del commit).

## 1. Revisiones de seguridad realizadas

| # | Etapa del SDLC | Herramienta / técnica | Build | Resultado (resumen) |
|---|---|---|---|---|
| R1 | Código (SAST) | Bandit en el pipeline | #4 / #5 | Inicial: 2 hallazgos High / 2 Medium / 1 Low. Tras mitigación: 0 hallazgos |
| R2 | Dependencias (SCA) | pip-audit en el pipeline | #5 | 19 vulnerabilidades en 4 paquetes (Flask, Werkzeug, Jinja2, gunicorn) |
| R3 | Pruebas dinámicas (DAST) | OWASP ZAP sobre staging | #__ | Pendiente de ejecución sobre staging (puerto 5001) |
| R4 | Revisión manual | Lectura de `app.py` | — | Se detectó XSS reflejado en `/hello`, ausencia de token anti-CSRF en `/login` y falta de cabeceras HTTP de seguridad |
| R5 | Producción | Grafana + Prometheus | — | Pendiente de monitorización en tiempo real (puerto 5000) |

## 2. Vulnerabilidades identificadas y corregidas

| ID | Vulnerabilidad (CWE) | Detectada por | Ubicación | Riesgo | Corrección aplicada | Commit | Build que lo verifica |
|---|---|---|---|---|---|---|---|
| VULN-01 | Credenciales y `SECRET_KEY` hardcodeadas (CWE-259) | Bandit (`B105`) | `app.py:20-23` | Bajo / Medio | Carga dinámica desde variables de entorno (`os.environ.get`) y generación segura con `secrets.token_hex(32)` | `fix(VULN-01..07)` | #5 |
| VULN-02 | Inyección SQL por concatenación de cadena (CWE-89) | Bandit (`B608`) | `app.py:205` | Alto | Reemplazo por consulta SQL parametrizada (`WHERE nombre LIKE ?`) y ocultamiento de trazas de error SQL | `fix(VULN-01..07)` | #5 |
| VULN-03 | Uso de hash criptográfico débil MD5 (CWE-327) | Bandit (`B324`) | `app.py:221` | Alto | Sustitución por `werkzeug.security.generate_password_hash` / `check_password_hash` y `hmac.compare_digest` | `fix(VULN-01..07)` | #5 |
| VULN-04 | Modo depuración activo en producción (CWE-94) | Bandit (`B201`) | `app.py:241` | Alto | Desactivación de `debug=True` estableciendo `debug=False` | `fix(VULN-01..07)` | #5 |
| VULN-05 | Enlace forzado a todas las interfaces `0.0.0.0` (CWE-605) | Bandit (`B104`) | `app.py:241` | Medio | Parametrización mediante `FLASK_HOST` con valor por defecto restringido a `127.0.0.1` | `fix(VULN-01..07)` | #5 |
| VULN-06 | Cross-Site Scripting (XSS) reflejado (CWE-79) | Revisión manual / DAST | `app.py:165` (`/hello`) | Medio | Sanitización de entrada mediante `markupsafe.escape()` antes de renderizar respuesta HTML | `fix(VULN-01..07)` | #5 |
| VULN-07 | Falta de token anti-CSRF y cabeceras HTTP seguras (CWE-352 / CWE-693) | Revisión manual / DAST | `app.py:72,143` | Medio | Implementación de `csrf_token` por sesión y cabeceras `X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy` y `Referrer-Policy` | `fix(VULN-01..07)` | #5 |

## 3. Resultados de OWASP ZAP

| Alerta de ZAP | Riesgo | URL de ejemplo | VULN relacionada | Cómo se mitiga | ¿Mitigada? Build |
|---|---|---|---|---|---|
| CSP: Failure to Define Directive with No Fallback (10055) | Medium | `http://127.0.0.1:5001/` | VULN-08 | Se añadieron las directivas explícitas `form-action 'self'`, `frame-ancestors 'none'` y `base-uri 'self'` en el header `Content-Security-Policy` | Sí (#9) |
| Cookie without SameSite Attribute (10054) | Medium | `http://127.0.0.1:5001/login` | VULN-08 | Se configuró `SESSION_COOKIE_SAMESITE = 'Lax'` y `SESSION_COOKIE_HTTPONLY = True` en la aplicación Flask | Sí (#9) |

## 4. Monitoreo e incidentes

| Hora | Panel / métrica de Grafana | Qué se observó | Entorno | Clasificación | Acción de respuesta | Verificación |
|---|---|---|---|---|---|---|
| 18:00 / 21:24 UTC | `Intentos de Login Fallidos` (`login_fallidos_total`) | Incremento súbito de peticiones `POST /login` rechazadas con código HTTP `401` desde `127.0.0.1` (registradas en `despliegues/produccion/access.log`) | Producción (`:5000`) y Staging (`:5001`) | Intento de fuerza bruta sobre autenticación | Correlación entre métricas de Grafana y `access.log` de producción; verificación de bloqueo de credenciales inválidas mediante `check_password_hash` y `hmac.compare_digest` sin accesos exitosos no autorizados | Contención confirmada (`401 Unauthorized` en todos los intentos) |
| 18:00 / 21:24 UTC | `Peticiones Sospechosas por Tipo de Ataque` (`peticiones_sospechosas_total`: `xss`, `sqli`, `path_traversal`) | Picos simultáneos de peticiones con payloads `<script>alert(1)</script>` en `/hello`, `' OR 1=1--` y `../../etc/passwd` en `/alumnos/buscar` | Producción (`:5000`) y Staging (`:5001`) | Sondeo e intento de explotación web (XSS, SQLi y Path Traversal) | Inspección de trazas en `access.log`, ejecución de prueba de contención contra `/alumnos/buscar?nombre=' OR 1=1--` y verificación de sanitización (`markupsafe.escape`) y consultas SQL parametrizadas | Sin fuga de datos (respuesta controlada `[]` y sin ejecución de scripts) |

## 5. Gestión de dependencias

| Paquete | Versión inicial | Vulnerabilidades (IDs) | Versión final | Origen del cambio (PR de Dependabot / manual) | ¿Pruebas, pip-audit y ZAP siguen OK? Build |
|---|---|---|---|---|---|
| Flask | 2.2.2 | | | | |
| Werkzeug | 2.2.2 | | | | |
| Jinja2 | 3.1.2 | | | | |
| gunicorn | 21.2.0 | | | | |
| prometheus-client | 0.17.1 | | | | |

## 6. Trazabilidad

Pega aquí (o adjunta) el `TRAZABILIDAD.md` del último build y completa un recorrido por cada actividad del pipeline:

| Actividad | Hallazgo | Build que lo detectó | Commit / PR que lo resolvió | Build que lo verificó | Versión en producción |
|---|---|---|---|---|---|
| Revisión de seguridad (Bandit) | | #__ | | #__ | |
| Prueba automatizada (OWASP ZAP) | | #__ | | #__ | |
| Gestión de dependencias (Dependabot) | | #__ | PR #__ | #__ | |
