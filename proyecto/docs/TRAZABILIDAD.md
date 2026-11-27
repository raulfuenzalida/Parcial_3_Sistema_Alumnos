# Registro de trazabilidad - Sistema Alumnos

Cada fila la agrega Jenkins al terminar un build (`scripts/trazabilidad.py`).

| Build | Fecha (UTC) | Versión | Commit | Mensaje del commit | Pruebas | Bandit H/M/L | pip-audit | ZAP H/M/L | Resultado | Producción |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 2026-11-27 19:40 | 1.0.1+bea96d7 | `bea96d7` | subir archivos de proyecto | 9/9 OK | n/a | n/a | n/a | SUCCESS | 1.0.1+bea96d7 |
| 3 | 2026-11-27 20:14 | 1.0.3+c2bc18b | `c2bc18b` | Configurar dir('proyecto') y etapas de seguridad en Jenkinsfile | 9/9 OK | n/a | n/a | n/a | FAILURE | no desplegado |
| 4 | 2026-11-27 20:16 | 1.0.4+2f12bf1 | `2f12bf1` | ajustes Jenkinsfile | 9/9 OK | 2/2/1 | n/a | n/a | FAILURE | no desplegado |
| 5 | 2026-11-27 20:22 | 1.0.5+4c164b2 | `4c164b2` | Mitigar SQLi, XSS, MD5, secretos hardcodeados y cabeceras en app.py | 9/9 OK | 0/0/0 | 20 vuln. | n/a | FAILURE | no desplegado |
| 6 | 2026-11-27 20:34 | 1.0.6+4c164b2 | `4c164b2` | Mitigar SQLi, XSS, MD5, secretos hardcodeados y cabeceras en app.py | 9/9 OK | 0/0/0 | 20 vuln. | n/a | FAILURE | no desplegado |
| 7 | 2026-11-27 20:40 | 1.0.7+c593f1e | `c593f1e` | fix(VULN-01..07): actualizar registro de seguridad y habilitar DAST OW | 9/9 OK | 0/0/0 | 20 vuln. | n/a | FAILURE | no desplegado |
| 8 | 2026-11-27 20:43 | 1.0.8+c593f1e | `c593f1e` | fix(VULN-01..07): actualizar registro de seguridad y habilitar DAST OW | 9/9 OK | 0/0/0 | 20 vuln. | n/a | FAILURE | no desplegado |
| 9 | 2026-11-27 20:46 | 1.0.9+1d4ffe9 | `1d4ffe9` | Pasar URL objetivo de staging a zap_scan.py | 9/9 OK | 0/0/0 | 20 vuln. | n/a | FAILURE | no desplegado |
| 10 | 2026-11-27 20:51 | 1.0.10+1d4ffe9 | `1d4ffe9` | Pasar URL objetivo de staging a zap_scan.py | 9/9 OK | 0/0/0 | 20 vuln. | 0/1/1 | FAILURE | no desplegado |
| 11 | 2026-11-27 20:59 | 1.0.11+d970365 | `d970365` | fix(VULN-08): endurecer directivas CSP y cookie SameSite | 9/9 OK | 0/0/0 | 20 vuln. | 0/0/0 | SUCCESS | 1.0.11+d970365 |
| 12 | 2026-11-27 21:34 | 1.0.12+3eee474 | `3eee474` | docs: documentar monitoreo en tiempo real y respuesta a incidentes | 9/9 OK | 0/0/0 | 20 vuln. | 0/0/0 | SUCCESS | 1.0.12+3eee474 |
| 13 | 2026-11-27 21:37 | 1.0.13+0556e12 | `0556e12` | ci(deps): configurar Dependabot para dependencias Python en /proyecto | 9/9 OK | 0/0/0 | 20 vuln. | 0/0/0 | SUCCESS | 1.0.13+0556e12 |
| 14 | 2026-11-27 21:51 | 1.0.14+bc7f70a | `bc7f70a` | Merge pull request #3 from raulfuenzalida/dependabot/pip/proyecto/guni | 0/1 OK | n/a | n/a | n/a | FAILURE | no desplegado |
| 15 | 2026-11-27 21:58 | 1.0.15+a99ee83 | `a99ee83` | Merge pull request #6 from raulfuenzalida/dependabot/pip/proyecto/jinj | 9/9 OK | 0/0/0 | 0 vuln. | 0/0/0 | SUCCESS | 1.0.15+a99ee83 |
| 16 | 2026-11-27 22:00 | 1.0.16+a99ee83 | `a99ee83` | Merge pull request #6 from raulfuenzalida/dependabot/pip/proyecto/jinj | 9/9 OK | 0/0/0 | 0 vuln. | 0/0/0 | SUCCESS | 1.0.16+a99ee83 |
| 17 | 2026-11-27 22:13 | 1.0.17+78dbaac | `78dbaac` | docs: completar registro de seguridad y trazabilidad final (Build #16) | 9/9 OK | 0/0/0 | 0 vuln. | 0/0/0 | SUCCESS | 1.0.17+78dbaac |
