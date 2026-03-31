# 🔐 Laboratorio de Seguridad Ofensiva con Docker

![Docker](https://img.shields.io/badge/Docker-Containerized-blue?logo=docker)
![Security](https://img.shields.io/badge/Security-Offensive-red)
![Nmap](https://img.shields.io/badge/Nmap-Scanning-green)
![Metasploit](https://img.shields.io/badge/Metasploit-Exploitation-orange)
![MySQL](https://img.shields.io/badge/MySQL-Database-blue)
![NGINX](https://img.shields.io/badge/NGINX-WebServer-green)
![Apache](https://img.shields.io/badge/Apache-WebServer-red)
![Status](https://img.shields.io/badge/Status-Ready-success)

---

## 🧭 Descripción

Este laboratorio permite simular un entorno controlado de pruebas de seguridad ofensiva, donde los estudiantes podrán:

- Identificar servicios expuestos  
- Analizar superficie de ataque  
- Detectar vulnerabilidades en aplicaciones web  
- Ejecutar pruebas de explotación controladas  

El entorno está completamente basado en contenedores Docker, lo que permite su despliegue rápido, reproducible y portable.

---

## 🏗️ Arquitectura del laboratorio

```mermaid
flowchart LR
    A[🖥️ Contenedor Atacante<br/>Nmap + Metasploit]

    subgraph Infraestructura del Laboratorio
        B[🌐 Aplicación CMS<br/>Apache + PHP]
        C[🎓 Aplicación Web Vulnerable<br/>SQL Injection]
        D[🌍 Servicio Web<br/>NGINX]
        E[(🗄️ Base de Datos MySQL)]
        F[🧰 phpMyAdmin<br/>(Opcional)]
    end

    A --> B
    A --> C
    A --> D

    B --> E
    C --> E
    F --> E
```

---

## 📦 Componentes del laboratorio

| Componente | Descripción | Tipo |
|----------|------------|------|
| 🖥️ Contenedor atacante | Herramientas de reconocimiento y explotación | Obligatorio |
| 🌐 CMS (Joomla) | Aplicación web sobre Apache | Obligatorio |
| 🎓 Portal vulnerable | Aplicación con vulnerabilidades de entrada | Obligatorio |
| 🌍 OVA (NGINX) | Servicio web adicional para análisis | Obligatorio |
| 🗄️ MySQL | Base de datos del entorno | Obligatorio |
| 🧰 phpMyAdmin | Administración de base de datos | Opcional |

---

## ⚙️ Requisitos

- Docker  
- Docker Compose  
- Git  

---

## 🚀 Despliegue del laboratorio

### 1. Clonar el repositorio

```bash
git clone https://github.com/danfelun/lab-fit-cp.git
cd lab-fit-cp
```

---

### 2. Configuración de variables de entorno (IMPORTANTE)

```bash
cp .env.example .env
```

Editar:

```bash
nano .env
```

👉 Ajuste credenciales y configuraciones necesarias.

⚠️ Este paso es obligatorio.

---

### 3. Construcción y despliegue

```bash
docker compose up -d --build
```

Contenedor atacante:

```bash
docker compose --profile attacker up -d --build
```

Opcionales:

```bash
docker compose --profile optional up -d --build
```

---

## 🧪 Uso del laboratorio

```bash
docker exec -it lab-attacker sh
```

```bash
nmap -sV <objetivo>
```

```bash
msfconsole
```

---

## 🎯 Enfoque pedagógico

- Descubrimiento activo de servicios  
- Identificación de tecnologías  
- Relación vulnerabilidad ↔ servicio  
- Explotación controlada  

---

## ⚠️ Consideraciones de seguridad

Uso exclusivo educativo.  
No exponer a internet.

---

## 🧩 Tecnologías

Docker, Apache, NGINX, MySQL, Nmap, Metasploit
