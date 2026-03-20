# Práctica — Base de Datos para Ride‑Hailing (Uber/Bolt/Lyft)

## Enunciado

En equipos de **4 personas**, diseñad e implementad una base de datos relacional para una plataforma de ride‑hailing.

**Caso de uso principal**: un **rider** solicita un viaje de **A** a **B** (A y B son **geolocalizaciones**). La solicitud genera una **oferta** que se envía a **múltiples conductores**, el **primer conductor que acepta** se queda el viaje y el pago. Cada conductor **pertenece a una company**.

## Alcance funcional mínimo

- Usuarios (rider y conductores) y sus perfiles.
- Conductores asociados a una company.
- Vehículos.
- Viajes con estado (`solicitado`, `aceptado`, `en curso`, `finalizado`, `cancelado`).
- Ofertas enviadas y decisiones de aceptación/rechazo. Asegurar que el primer conductor que acepta se queda el viaje y el pago. No puede haber dos conductores aceptando la misma oferta.
- Historial y auditoría básica de operaciones.

## Requisitos operativos y métricas

- Tasa de aceptación por conductor y por company.
- Tiempo medio y kilometraje medio de los viajes.
- Ingresos por conductor y por company, euros/km y euros/minuto.
- Dashboard de métricas de **base de datos** para monitorización.
- Dashboard de métricas de **negocio** (viajes por hora, ofertas aceptadas, etc.).
- Plan de backup y recuperación. Desarrollarlo y justificarlo.
- Usuarios de base de datos para la seguridad del sistema. Desarrollarlos y justificarlos.

## Entregables esperados

- MER y scripts: creación, carga, consultas, updates, deletes y permisos.
- Carga masiva de usuarios, vehículos, viajes y ofertas.
- Desarrollar **índices** para mejorar el rendimiento de las consultas.
- Consultas para el dashboard y la operativa básica (insertar ofertas, viajes, usuarios, etc.).
- Al menos una consulta con **locks** por concurrencia y varias con **transacciones** y **joins**.
- Un `.md` con instrucciones para arrancar la base de datos y el dashboard, y cargar datos de prueba.
- Uso de Docker y Docker Compose para el despliegue.

A partir de aquí, crea las **tablas**, **consultas**, **índices**, **vistas**, lo que sea que consideres necesario para cubrir el enunciado e incluso mejorarlo.

Al final, el día de la defensa, se debe presentar el proyecto, explicando el diseño, las tablas, índices, consultas, etc. Debe ser una presentación en PowerPoint o similar. Cada grupo tendrá una calificación grupal y una calificación individual.

## Nombre de cada entregable

- `schema.sql`: esquema de la base de datos, crea la base de datos, las tablas e índices.
- `data.sql`: datos de prueba, inserta datos de prueba en las tablas.
- `queries.sql`: consultas para la operativa.
- `dashboard.sql`: consultas para el dashboard.
- `backup.sql`: plan de backup y recuperación.
- `permissions.sql`: permisos para la seguridad del sistema.
- `compose.yml`: despliegue de la base de datos y el dashboard.
- `README.md`: instrucciones para arrancar la base de datos y el dashboard, y cargar datos de prueba.
- `DESIGN.md`: explica el diseño de la base de datos, las tablas, índices, etc. Usar Markdown y Mermaid (sobre todo para el MER).
- `presentacion.pdf`: presentación del proyecto, usar un PowerPoint o similar para el día de la defensa. Indicar los integrantes del equipo y la aportación de cada uno.
