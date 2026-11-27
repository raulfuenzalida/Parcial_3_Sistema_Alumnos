# Jenkins + las herramientas que usa el pipeline del examen.
# Base oficial de Jenkins (Debian) con Python, Git y curl; las herramientas de seguridad van en un venv aislado.
FROM jenkins/jenkins:lts-jdk21

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 python3-venv python3-pip git curl \
 && rm -rf /var/lib/apt/lists/*

# Bandit (análisis estático, SAST) y pip-audit (dependencias con CVE, SCA)
RUN python3 -m venv /opt/herramientas \
 && /opt/herramientas/bin/pip install --no-cache-dir bandit==1.8.6 pip-audit==2.9.0
ENV PATH="/opt/herramientas/bin:${PATH}"

USER jenkins
# Plugins que usa el Jenkinsfile (el asistente inicial instalará además los sugeridos)
RUN jenkins-plugin-cli --plugins workflow-aggregator git junit timestamper pipeline-stage-view
