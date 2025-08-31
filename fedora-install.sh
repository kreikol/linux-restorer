#!/bin/bash

# --- Verificación de Git ---
if ! command -v git >/dev/null 2_>&1; then
    echo "   [INFO] Git no está instalado y es necesario para continuar."
    echo "   [INFO] El script intentará instalarlo usando 'sudo dnf install git'."
    read -p "   ¿Deseas continuar con la instalación? (s/N): " confirmacion
    if [[ "$confirmacion" =~ ^[sS]$ ]]; then
        echo "   [INFO] Instalando Git..."
        if sudo dnf install -y git; then
            echo "   [INFO] Git se ha instalado correctamente."
        else
            echo "❌ [ERROR] La instalación de Git ha fallado. Abortando." >&2
            exit 1
        fi
    else
        echo "   [INFO] Instalación cancelada por el usuario. Abortando."
        exit 0
    fi
fi
# --- Fin de la verificación de Git ---



# fedora-install.sh
#
# Un script para automatizar la clonación de un repositorio de dotfiles
# del usuario 'kreikol' desde GitHub y ejecutar su script de instalación.
#
# Uso:
# ./fedora-install.sh <repositorio> <ruta_a_la_clave_ssh>
#
# Ejemplo:
# ./fedora-install.sh dotfiles ~/.ssh/id_github

# --- Funciones de logging ---
log_info() {
    echo "   [INFO] $(date +'%T') $1"
}

log_error() {
    # Imprime en stderr
    echo "❌ [ERROR] $(date +'%T') $1" >&2
}

# --- Verificación de parámetros de entrada ---
if [ "$#" -ne 2 ]; then
    log_error "Uso: $0 <repositorio> <ruta_a_la_clave_ssh>"
    log_error "Ejemplo: $0 dotfiles ~/.ssh/id_ed25519"
    exit 1
fi

REPO_ARG="$1"
SSH_KEY_PATH="$2"
GITHUB_USER="kreikol"
REPO_NAME="${GITHUB_USER}/${REPO_ARG}"


if [ ! -f "$SSH_KEY_PATH" ]; then
    log_error "La clave SSH no se encuentra en la ruta: $SSH_KEY_PATH"
    exit 1
fi

# --- Inicio del agente SSH y carga de la clave ---
log_info "🔑 Iniciando el agente SSH para esta sesión..."
# El eval es necesario para que las variables de entorno del agente se carguen en el shell actual
eval "$(ssh-agent -s)" > /dev/null

log_info "   Añadiendo la clave SSH al agente: $SSH_KEY_PATH"
ssh-add "$SSH_KEY_PATH"
if [ $? -ne 0 ]; then
    log_error "No se pudo añadir la clave SSH. Verifica la ruta y/o la contraseña de la clave."
    # Detenemos el agente antes de salir
    kill $SSH_AGENT_PID
    exit 1
fi

# --- Petición de la ruta de destino ---
DEFAULT_DEST_PATH="$HOME/.dotfiles"
read -p "📂 Introduce la ruta de destino para clonar (por defecto: ${DEFAULT_DEST_PATH}): " USER_DEST_PATH

# Si el usuario no introduce nada, usamos la ruta por defecto
DEST_PATH="${USER_DEST_PATH:-$DEFAULT_DEST_PATH}"

# Expande el ~ a la ruta del home del usuario si es necesario
DEST_PATH="${DEST_PATH/#\~/$HOME}"

if [ -d "$DEST_PATH" ]; then
    echo  # Salto de línea para mejorar la legibilidad
    log_error "El directorio de destino '$DEST_PATH' ya existe."
    read -p "   ¿Deseas borrarlo y continuar? (s/n): " CONFIRM
    echo
    if [[ "$CONFIRM" == [sS] || "$CONFIRM" == [sS][iI] ]]; then
        log_info "Eliminando el directorio existente..."
        rm -rf "$DEST_PATH"
        if [ $? -ne 0 ]; then
            log_error "No se pudo eliminar el directorio. Saliendo."
            kill $SSH_AGENT_PID
            exit 1
        fi
        log_info "Directorio eliminado con éxito."
    else
        log_info "Operación cancelada por el usuario. Saliendo."
        kill $SSH_AGENT_PID
        exit 1
    fi
fi

# --- Clonación del repositorio ---
GIT_URL="git@github.com:${REPO_NAME}.git"
log_info "🐙 Clonando el repositorio '${REPO_NAME}' en '${DEST_PATH}'..."

git clone "${GIT_URL}" "${DEST_PATH}"
if [ $? -ne 0 ]; then
    log_error "Falló la clonación del repositorio."
    log_error "Verifica que el nombre del repositorio ('${REPO_ARG}') es correcto y que la clave SSH tiene acceso."
    kill $SSH_AGENT_PID
    exit 1
fi

log_info "   Repositorio clonado con éxito."

# --- Inicialización de submódulos ---
log_info "🌿 Inicializando y actualizando submódulos de Git..."
(cd "$DEST_PATH" && git submodule update --init --recursive)
if [ $? -ne 0 ]; then
    log_error "Falló la inicialización de los submódulos."
    kill $SSH_AGENT_PID
    exit 1
fi
log_info "   Submódulos inicializados correctamente."

# --- Ejecución del script de instalación ---
INSTALL_SCRIPT_PATH="${DEST_PATH}/install.sh"
log_info "   Buscando el script de instalación en: ${INSTALL_SCRIPT_PATH}"

if [ -f "$INSTALL_SCRIPT_PATH" ]; then
    log_info "   Script 'install.sh' encontrado. Dando permisos de ejecución..."
    chmod +x "$INSTALL_SCRIPT_PATH"

    log_info "⚙️  Ejecutando el script de instalación..."
    # Usamos un subshell para que el cambio de directorio no afecte al script principal
    (cd "$DEST_PATH" && ./install.sh)

    if [ $? -eq 0 ]; then
        log_info "   El script de instalación se ejecutó correctamente."
    else
        log_error "El script de instalación finalizó con un error."
    fi
else
    log_error "No se encontró el script 'install.sh' en la raíz del repositorio."
    log_error "La instalación no se ha completado."
fi

# --- Limpieza ---
log_info "🧹 Limpiando la sesión del agente SSH..."
kill $SSH_AGENT_PID

log_info "✅ Proceso completado."