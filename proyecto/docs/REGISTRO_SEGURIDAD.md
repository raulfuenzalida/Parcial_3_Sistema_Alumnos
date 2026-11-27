# Registro de seguridad · Sistema Alumnos

Estudiante: ____________________   Repositorio: ____________________   Fecha: __________

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
| | | | | | |

## 4. Monitoreo e incidentes

| Hora | Panel / métrica de Grafana | Qué se observó | Entorno | Clasificación | Acción de respuesta | Verificación |
|---|---|---|---|---|---|---|
| | | | | | | |

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
