# Linux Restorer

Este repositorio contiene una colección de scripts para automatizar la configuración inicial de un entorno de desarrollo en sistemas Linux.

## Scripts Disponibles

### 1. Instalador de Dotfiles para Fedora (`fedora-install.sh`)

Este script automatiza la clonación de un repositorio de dotfiles del usuario `kreikol` desde GitHub y ejecuta un script de instalación (`install.sh`) que se encuentre en la raíz de dicho repositorio.

#### Instalación Rápida (Online)

Si prefieres no clonar este repositorio, puedes ejecutar el script directamente desde GitHub con un único comando.

> **Nota de seguridad:** Ejecutar scripts directamente desde internet con `bash` requiere confianza en el contenido del mismo. Se recomienda revisar el código del script antes de ejecutarlo.

```bash
# Reemplaza <nombre_repo> con tu repositorio de dotfiles; y <ruta_clave_ssh> por la clave ssh para acceder a tu repositorio de dotfiles
bash <(curl -sL https://raw.githubusercontent.com/kreikol/linux-restorer/HEAD/fedora-install.sh) <nombre_repo> <ruta_clave_ssh>
```

#### Requisitos

-   Tener `git` y `ssh` instalados en el sistema.
-   Una clave SSH con acceso a los repositorios del usuario `kreikol` en GitHub.

#### Uso Local

Si has clonado este repositorio, puedes ejecutar el script localmente.

1.  **Dar permisos de ejecución al script:**
    ```bash
    chmod +x fedora-install.sh
    ```

2.  **Ejecutar el script:**
    ```bash
    ./fedora-install.sh <nombre_del_repositorio> <ruta_a_la_clave_ssh>
    ```

    **Ejemplo:**
    ```bash
    # Clona 'kreikol/dotfiles' usando la clave '~/.ssh/id_github'
    ./fedora-install.sh dotfiles ~/.ssh/id_github
    ```

---

### 2. Restaurador de Entorno para Ubuntu (`restorer-ubuntu`)

Este script está diseñado para restaurar un entorno de desarrollo específico en **Ubuntu**. Realiza una actualización completa del sistema y clona un repositorio de dotfiles del usuario `kreikol` para configurar un entorno basado en `dotly`.

> **Importante:** Este script ejecutará comandos con `sudo` para actualizar el sistema y está configurado para clonar repositorios específicamente del usuario de GitHub **`kreikol`**.

#### Instalación Rápida (Online)

```bash
# Reemplaza <nombre_repo> con tu repositorio de dotfiles; y <ruta_clave_ssh> por la clave ssh para acceder a tu repositorio de dotfiles
bash <(curl -sL https://raw.githubusercontent.com/kreikol/linux-restorer/HEAD/restorer-ubuntu) <nombre_repo> <ruta_clave_ssh>
```

#### Requisitos

-   Un sistema basado en Ubuntu.
-   Tener `git`, `curl` y `ssh` instalados.
-   Una clave SSH con acceso a los repositorios del usuario `kreikol` en GitHub.

#### Uso Local

1.  **Dar permisos de ejecución:**
    ```bash
    chmod +x restorer-ubuntu
    ```

2.  **Ejecutar el script:**
    ```bash
    ./restorer-ubuntu <nombre_del_repositorio> <ruta_a_la_clave_ssh>
    ```

    **Ejemplo:**
    ```bash
    # Clona 'dotfiles' del usuario 'kreikol' usando la clave '~/.ssh/id_rsa'
    ./restorer-ubuntu dotfiles ~/.ssh/id_rsa
    ```
