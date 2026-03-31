# 🔐 Laboratorio de Seguridad Ofensiva con Docker

![Docker](https://img.shields.io/badge/Docker-Containerized-blue?logo=docker)
![Security](https://img.shields.io/badge/Security-Offensive-red)
![Nmap](https://img.shields.io/badge/Nmap-Scanning-green)
![Metasploit](https://img.shields.io/badge/Metasploit-Exploitation-orange)
![MySQL](https://img.shields.io/badge/MySQL-Database-blue)
![NGINX](https://img.shields.io/badge/NGINX-WebServer-green)
![Apache](https://img.shields.io/badge/Apache-WebServer-red)
![Status](https://img.shields.io/badge/Status-Ready-success)

## 🏗️ Arquitectura

```mermaid
graph TD
    A[Atacante\nNmap + Metasploit]
    B[Joomla 8080]
    C[Portal 8081]
    D[MySQL 3306]
    E[phpMyAdmin 8082]
    F[OVA 8083]

    A --> B
    A --> C
    A --> F
    B --> D
    C --> D
    E --> D
```

## 🚀 Despliegue

```bash
docker compose up -d --build
docker compose --profile attacker up -d --build
docker compose --profile optional up -d --build
```

## ⚠️ Uso educativo
Solo para entornos controlados.
