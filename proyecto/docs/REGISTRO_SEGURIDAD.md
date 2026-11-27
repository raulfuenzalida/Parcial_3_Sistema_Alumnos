# Registro de seguridad · Sistema Alumnos

Estudiante: Raúl Fuenzalida   Repositorio: https://github.com/raulfuenzalida/Parcial_3_Sistema_Alumnos.git   Fecha: 27/11/2026

Completa este registro a medida que avanzas. Cada fila debe poder seguirse hasta un **build de Jenkins**
y un **commit** (usa el identificador `VULN-xx` en el mensaje del commit).

## 1. Revisiones de seguridad realizadas

| # | Etapa del SDLC | Herramienta / técnica | Build | Resultado (resumen) |
|---|---|---|---|---|
| R1 | Código (SAST) | Bandit en el pipeline | #4 / #5 | Inicial: 2 hallazgos High / 2 Medium / 1 Low. Tras mitigación (`VULN-01..05`): 0 hallazgos |
| R2 | Dependencias (SCA) | pip-audit + Dependabot | #5 / #16 | Inicial: 19 vulnerabilidades en 4 paquetes. Tras merge de PRs `#1`..`#6` de Dependabot: 0 vulnerabilidades |
| R3 | Pruebas dinámicas (DAST) | OWASP ZAP sobre staging | #8 / #9 | Inicial: 3 alertas Medium (`CSP` sin fallback y cookie sin `SameSite`). Tras mitigación (`VULN-08`): High=0, Medium=0, Low=0 |
| R4 | Revisión manual | Lectura de `app.py` | — | Se detectó XSS reflejado en `/hello`, ausencia de token anti-CSRF en `/login` y falta de cabeceras HTTP de seguridad |
| R5 | Producción | Grafana + Prometheus | #9 / #16 | Monitorización en tiempo real (`job="produccion"` y `job="staging"`): detección de fuerza bruta (`login_fallidos_total`) e inyecciones (`peticiones_sospechosas_total`: `xss`, `sqli`, `path_traversal`) |

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
| Flask | 2.2.2 | GHSA-m2qf-hwjv-5gpq / CVE-2023-30861 | 3.1.3 | PR #4 (`dependabot[bot]`) | Sí (#16) |
| Werkzeug | 2.2.2 | CVE-2023-25577, CVE-2023-23934, CVE-2023-46136, CVE-2024-34069, CVE-2024-49766, CVE-2024-49767 | 3.1.9 | PR #1 (`dependabot[bot]`) | Sí (#16) |
| Jinja2 | 3.1.2 | CVE-2024-22195, CVE-2024-34064, CVE-2024-56201, CVE-2024-56326, CVE-2025-27516 | 3.1.6 | PR #6 (`dependabot[bot]`) | Sí (#16) |
| gunicorn | 21.2.0 | CVE-2024-1135, CVE-2024-6827 | 27.0.1 | PR #3 (`dependabot[bot]`) | Sí (#16) |
| prometheus-client | 0.17.1 | Sin CVEs críticos (actualización preventiva de mantenimiento) | 0.26.0 | PR #5 (`dependabot[bot]`) | Sí (#16) |

## 6. Trazabilidad

Pega aquí (o adjunta) el `TRAZABILIDAD.md` del último build y completa un recorrido por cada actividad del pipeline:

| Build | Fecha | Versión | Commit | Mensaje | Pruebas | SAST (H/M/L) | SCA (`pip-audit`) | DAST ZAP (H/M/L) | Resultado | Artefacto desplegado |
|---|---|---|---|---|---|---|---|---|---|---|
| 16 | 2026-11-27 22:00 | 1.0.16+a99ee83 | `a99ee83` | Merge pull request #6 from raulfuenzalida/dependabot/pip/proyecto/jinja2-3.1.6 | 9/9 OK | 0/0/0 | 0 vuln. | 0/0/0 | SUCCESS | 1.0.16+a99ee83 |

| Actividad | Hallazgo | Build que lo detectó | Commit / PR que lo resolvió | Build que lo verificó | Versión en producción |
|---|---|---|---|---|---|
| Revisión de seguridad (Bandit) | 2 High, 2 Medium, 1 Low (`VULN-01..05`) | #4 | `fix(VULN-01..07)` | #5 | `1.0.16+a99ee83` (`:5000`) |
| Prueba automatizada (OWASP ZAP) | 3 alertas Medium (`VULN-08`: CSP y cookie sin `SameSite`) | #8 | `fix(VULN-08)` | #9 | `1.0.16+a99ee83` (`:5000`) |
| Gestión de dependencias (Dependabot + pip-audit) | 19 vulnerabilidades en `Flask`, `Werkzeug`, `Jinja2` y `gunicorn` | #5 | PR #1, #3, #4, #5, #6 (`dependabot[bot]`) | #16 | `1.0.16+a99ee83` (`:5000`) |
