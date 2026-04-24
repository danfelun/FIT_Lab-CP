#!/usr/bin/env bash
# =============================================================================
#  FIT_Lab-CP — Script de despliegue automatizado
#  Autor:  Adaptado para uso pedagógico en posgrado de Seguridad Informática
#  Repo:   https://github.com/danfelun/FIT_Lab-CP
#  SO:     Ubuntu Server 22.04 LTS / 24.04 LTS
#  Uso:    sudo bash fitlab_setup.sh
# =============================================================================

set -euo pipefail

# ─── Colores para salida ──────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Variables configurables ──────────────────────────────────────────────────
REPO_URL="https://github.com/danfelun/FIT_Lab-CP.git"
INSTALL_DIR="/opt/fitlab"
SERVICE_NAME="fitlab"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
LOG_FILE="/var/log/fitlab_setup.log"

# ─── Funciones de salida ──────────────────────────────────────────────────────
log()     { echo -e "${CYAN}[INFO]${NC}  $*" | tee -a "$LOG_FILE"; }
ok()      { echo -e "${GREEN}[OK]${NC}    $*" | tee -a "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*" | tee -a "$LOG_FILE"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"; exit 1; }
section() { echo -e "\n${BOLD}${CYAN}══════════════════════════════════════${NC}"; \
            echo -e "${BOLD}${CYAN}  $*${NC}"; \
            echo -e "${BOLD}${CYAN}══════════════════════════════════════${NC}\n"; }

# ─── Verificaciones previas ───────────────────────────────────────────────────
preflight_checks() {
    section "Verificaciones previas"

    # Debe ejecutarse como root
    [[ $EUID -eq 0 ]] || error "Ejecuta el script como root: sudo bash $0"

    # Detectar Ubuntu
    if ! grep -qi "ubuntu" /etc/os-release 2>/dev/null; then
        warn "Este script está optimizado para Ubuntu. Continúa bajo tu propia responsabilidad."
    else
        UBUNTU_VERSION=$(lsb_release -rs 2>/dev/null || echo "desconocida")
        log "Sistema detectado: Ubuntu $UBUNTU_VERSION"
    fi

    # Conectividad a internet
    log "Comprobando conectividad..."
    if ! curl -fsSL --max-time 10 https://google.com -o /dev/null 2>/dev/null; then
        error "Sin acceso a internet. Verifica la configuración de red de la VM."
    fi
    ok "Conectividad verificada."

    # Inicializar log
    touch "$LOG_FILE"
    log "Log en: $LOG_FILE"
}

# ─── Etapa 1: Actualizar el sistema ──────────────────────────────────────────
update_system() {
    section "Etapa 1 — Actualización del sistema"

    log "Ejecutando apt update..."
    apt-get update -qq | tee -a "$LOG_FILE"

    log "Ejecutando apt upgrade..."
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq | tee -a "$LOG_FILE"

    log "Instalando dependencias base..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        curl \
        git \
        ca-certificates \
        gnupg \
        lsb-release \
        apt-transport-https \
        net-tools \
        2>&1 | tee -a "$LOG_FILE"

    ok "Sistema actualizado y dependencias instaladas."
}

# ─── Etapa 2: Instalar Docker Engine + Compose plugin ────────────────────────
install_docker() {
    section "Etapa 2 — Instalación de Docker"

    # Verificar si Docker ya está instalado
    if command -v docker &>/dev/null; then
        DOCKER_VER=$(docker --version)
        warn "Docker ya está instalado: $DOCKER_VER"
        log "Omitiendo instalación de Docker."
    else
        log "Agregando clave GPG oficial de Docker..."
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
            | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg

        log "Agregando repositorio de Docker..."
        echo \
            "deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" \
            | tee /etc/apt/sources.list.d/docker.list > /dev/null

        apt-get update -qq | tee -a "$LOG_FILE"

        log "Instalando Docker Engine y Compose plugin..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            docker-ce \
            docker-ce-cli \
            containerd.io \
            docker-buildx-plugin \
            docker-compose-plugin \
            2>&1 | tee -a "$LOG_FILE"

        ok "Docker instalado correctamente."
    fi

    # Verificar versiones instaladas
    docker --version | tee -a "$LOG_FILE"
    docker compose version | tee -a "$LOG_FILE"

    # Habilitar y arrancar el daemon de Docker
    log "Habilitando Docker en el arranque del sistema..."
    systemctl enable docker --quiet
    systemctl start docker

    # Agregar el usuario invocador (el que usó sudo) al grupo docker
    REAL_USER="${SUDO_USER:-}"
    if [[ -n "$REAL_USER" ]] && id "$REAL_USER" &>/dev/null; then
        if ! groups "$REAL_USER" | grep -q docker; then
            usermod -aG docker "$REAL_USER"
            ok "Usuario '$REAL_USER' agregado al grupo docker."
            warn "Cierra sesión y vuelve a entrar para que el grupo surta efecto sin sudo."
        else
            log "El usuario '$REAL_USER' ya pertenece al grupo docker."
        fi
    fi

    ok "Docker listo."
}

# ─── Etapa 3: Clonar el repositorio ──────────────────────────────────────────
clone_repository() {
    section "Etapa 3 — Clonación del repositorio"

    if [[ -d "$INSTALL_DIR/.git" ]]; then
        warn "El directorio $INSTALL_DIR ya existe y es un repositorio git."
        log "Ejecutando git pull para actualizar..."
        git -C "$INSTALL_DIR" pull 2>&1 | tee -a "$LOG_FILE"
    else
        if [[ -d "$INSTALL_DIR" ]]; then
            warn "$INSTALL_DIR existe pero no es un repo git. Se eliminará."
            rm -rf "$INSTALL_DIR"
        fi
        log "Clonando $REPO_URL en $INSTALL_DIR..."
        git clone "$REPO_URL" "$INSTALL_DIR" 2>&1 | tee -a "$LOG_FILE"
    fi

    # Asignar permisos
    REAL_USER="${SUDO_USER:-root}"
    chown -R "$REAL_USER":"$REAL_USER" "$INSTALL_DIR" 2>/dev/null || true

    ok "Repositorio disponible en $INSTALL_DIR"

    # Mostrar estructura del proyecto
    log "Estructura del proyecto:"
    ls -la "$INSTALL_DIR" | tee -a "$LOG_FILE"
}

# ─── Etapa 4: Verificar configuración del stack ───────────────────────────────
verify_stack() {
    section "Etapa 4 — Verificación de configuración"

    cd "$INSTALL_DIR"

    # Verificar que existe un compose file
    COMPOSE_FILE=""
    for f in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
        if [[ -f "$INSTALL_DIR/$f" ]]; then
            COMPOSE_FILE="$f"
            break
        fi
    done
    [[ -n "$COMPOSE_FILE" ]] || error "No se encontró ningún archivo compose en $INSTALL_DIR"
    ok "Compose file encontrado: $COMPOSE_FILE"

    # Verificar archivos .env
    ENV_FILES=$(find "$INSTALL_DIR" -maxdepth 2 -name "*.env" -o -name ".env" 2>/dev/null | sort)
    if [[ -n "$ENV_FILES" ]]; then
        log "Archivos .env detectados:"
        echo "$ENV_FILES" | tee -a "$LOG_FILE"
    else
        warn "No se detectaron archivos .env. Verifica si el stack los requiere."
    fi

    # Validar que el compose file es parseable
    log "Validando sintaxis del compose file..."
    if docker compose -f "$INSTALL_DIR/$COMPOSE_FILE" config --quiet 2>>"$LOG_FILE"; then
        ok "Sintaxis del compose file válida."
    else
        error "El compose file tiene errores de sintaxis. Revisa $LOG_FILE para detalles."
    fi

    # Mostrar resumen de servicios y puertos definidos
    log "Servicios y puertos definidos en el stack:"
    docker compose -f "$INSTALL_DIR/$COMPOSE_FILE" config --services 2>/dev/null \
        | tee -a "$LOG_FILE"

    echo ""
    log "Puertos expuestos (ports mapping):"
    docker compose -f "$INSTALL_DIR/$COMPOSE_FILE" config 2>/dev/null \
        | grep -E "^\s+- \"[0-9]" | sort -u | tee -a "$LOG_FILE" || \
        warn "No se pudieron extraer los puertos. Revisa manualmente el compose file."
}

# ─── Etapa 5: Prueba de arranque del stack ────────────────────────────────────
test_stack() {
    section "Etapa 5 — Prueba de arranque"

    COMPOSE_FILE=""
    for f in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
        [[ -f "$INSTALL_DIR/$f" ]] && { COMPOSE_FILE="$f"; break; }
    done

    log "Descargando imágenes (puede tardar varios minutos)..."
    docker compose -f "$INSTALL_DIR/$COMPOSE_FILE" pull 2>&1 | tee -a "$LOG_FILE"

    log "Levantando el stack en modo detached..."
    docker compose -f "$INSTALL_DIR/$COMPOSE_FILE" up -d --remove-orphans \
        2>&1 | tee -a "$LOG_FILE"

    # Esperar unos segundos para que los contenedores inicialicen
    log "Esperando 8 segundos para estabilización de contenedores..."
    sleep 8

    log "Estado actual del stack:"
    docker compose -f "$INSTALL_DIR/$COMPOSE_FILE" ps 2>&1 | tee -a "$LOG_FILE"

    # Verificar que no haya contenedores en estado Exit
    FAILED=$(docker compose -f "$INSTALL_DIR/$COMPOSE_FILE" ps --status exited \
        --format "{{.Name}}" 2>/dev/null || true)
    if [[ -n "$FAILED" ]]; then
        warn "Los siguientes contenedores finalizaron inesperadamente:"
        echo "$FAILED" | tee -a "$LOG_FILE"
        warn "Revisa sus logs con: docker logs <nombre_contenedor>"
    else
        ok "Todos los contenedores están activos."
    fi

    log "Bajando el stack para configurar el servicio systemd..."
    docker compose -f "$INSTALL_DIR/$COMPOSE_FILE" down 2>&1 | tee -a "$LOG_FILE"
}

# ─── Etapa 6: Crear y habilitar el servicio systemd ──────────────────────────
create_systemd_service() {
    section "Etapa 6 — Configuración del servicio systemd"

    # Detectar compose file
    COMPOSE_FILE=""
    for f in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
        [[ -f "$INSTALL_DIR/$f" ]] && { COMPOSE_FILE="$f"; break; }
    done
    COMPOSE_FULL_PATH="$INSTALL_DIR/$COMPOSE_FILE"
    DOCKER_BIN=$(command -v docker)

    log "Creando unit file en $SERVICE_FILE..."

    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=FIT Lab — Stack de contenedores vulnerables (laboratorio pedagogico)
Documentation=https://github.com/danfelun/FIT_Lab-CP
After=docker.service network-online.target
Wants=network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=${INSTALL_DIR}

ExecStart=${DOCKER_BIN} compose -f ${COMPOSE_FULL_PATH} up -d --remove-orphans
ExecStop=${DOCKER_BIN} compose -f ${COMPOSE_FULL_PATH} down

Restart=on-failure
RestartSec=15s
StartLimitIntervalSec=90s
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF

    ok "Unit file creado."

    log "Recargando configuración de systemd..."
    systemctl daemon-reload

    log "Habilitando el servicio para arranque automático..."
    systemctl enable "${SERVICE_NAME}.service" --quiet

    log "Iniciando el servicio..."
    systemctl start "${SERVICE_NAME}.service"

    sleep 5

    if systemctl is-active --quiet "${SERVICE_NAME}.service"; then
        ok "Servicio ${SERVICE_NAME}.service activo y habilitado."
    else
        warn "El servicio no reporta estado 'active'. Revisa con:"
        warn "  journalctl -u ${SERVICE_NAME}.service -n 50"
    fi
}

# ─── Resumen final ────────────────────────────────────────────────────────────
print_summary() {
    section "Despliegue completado"

    VM_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "IP no detectada")

    echo -e "${BOLD}  Directorio del stack :${NC} $INSTALL_DIR"
    echo -e "${BOLD}  Servicio systemd      :${NC} ${SERVICE_NAME}.service"
    echo -e "${BOLD}  IP de la VM           :${NC} $VM_IP"
    echo -e "${BOLD}  Log del proceso       :${NC} $LOG_FILE"
    echo ""
    echo -e "${BOLD}  Contenedores activos:${NC}"
    docker ps --format "  • {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || true
    echo ""
    echo -e "${BOLD}${CYAN}  Comandos de operación útiles:${NC}"
    echo -e "  Ver estado del stack    :  docker compose -f $INSTALL_DIR/$COMPOSE_FILE ps"
    echo -e "  Logs en tiempo real     :  docker compose -f $INSTALL_DIR/$COMPOSE_FILE logs -f"
    echo -e "  Detener el lab          :  sudo systemctl stop ${SERVICE_NAME}.service"
    echo -e "  Reiniciar el lab        :  sudo systemctl restart ${SERVICE_NAME}.service"
    echo -e "  Estado del servicio     :  sudo systemctl status ${SERVICE_NAME}.service"
    echo -e "  Actualizar repo (nuevo semestre):  cd $INSTALL_DIR && git pull"
    echo -e "                                     sudo systemctl restart ${SERVICE_NAME}.service"
    echo ""
    ok "El stack arrancará automáticamente en cada reinicio de la VM."
}

# ─── Punto de entrada ─────────────────────────────────────────────────────────
main() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo "  ███████╗██╗████████╗    ██╗      █████╗ ██████╗ "
    echo "  ██╔════╝██║╚══██╔══╝    ██║     ██╔══██╗██╔══██╗"
    echo "  █████╗  ██║   ██║       ██║     ███████║██████╔╝"
    echo "  ██╔══╝  ██║   ██║       ██║     ██╔══██║██╔══██╗"
    echo "  ██║     ██║   ██║       ███████╗██║  ██║██████╔╝"
    echo "  ╚═╝     ╚═╝   ╚═╝       ╚══════╝╚═╝  ╚═╝╚═════╝ "
    echo -e "${NC}"
    echo -e "  ${BOLD}Script de despliegue — FIT_Lab-CP${NC}"
    echo -e "  Laboratorio de Pentesting — Posgrado en Seguridad Informática"
    echo -e "  Repositorio: $REPO_URL"
    echo ""

    preflight_checks
    update_system
    install_docker
    clone_repository
    verify_stack
    test_stack
    create_systemd_service
    print_summary
}

main "$@"
