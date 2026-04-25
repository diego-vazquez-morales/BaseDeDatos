# Ride-Hailing Database

Base de datos relacional desplegada con Docker y MySQL 8.0.


## Debe tener lo siguiente para poder arrancar la base de datos

- [Docker](https://docs.docker.com/get-docker/) y [Docker Compose](https://docs.docker.com/compose/install/) instalados.
- Puerto `3306` libre en tu máquina.


## Arranque rápido

### 1. Levantar la base de datos

```bash
docker compose up -d
```

Espera a que el contenedor pase el healthcheck (puede tardar ~20 segundos en el primer arranque):

```bash
docker compose ps
# mysql   ...   healthy
```

### 2. Cargar el esquema

```bash
docker exec -i mysql mysql -uroot -prootpass rideHailing < schema.sql

#este es el que funciona
type schema.sql | docker exec -i mysql mysql -uroot -prootpass

```

### 3. Cargar los datos de prueba

```bash
docker exec -i mysql mysql -uroot -prootpass rideHailing < data.sql

#este funciona 
type data.sql | docker exec -i mysql mysql -uroot -prootpass

```

### 4. Aplicar permisos

```bash
docker exec -i mysql mysql -uroot -prootpass rideHailing < permissions.sql
#este funciona
type permissions.sql | docker exec -i mysql mysql -uroot -prootpass

```

### 5. (Opcional) Cargar consultas del dashboard

```bash
docker exec -i mysql mysql -uroot -prootpass rideHailing < dashboard.sql

#este funciona 
type dashboard.sql | docker exec -i mysql mysql -uroot -prootpass
```


### 6. Ejecutar a mano el backuo

```bash
bash backup.sh

```
## Conexión a la base de datos

| Parámetro  | Valor        |
|------------|--------------|
| Host       | `localhost`  |
| Puerto     | `3306`       |
| Base datos | `rideHailing`|
| Usuario    | `app`        |
| Contraseña | `apppass`    |

Conexión desde la terminal:

```bash
# Con el usuario de aplicación
mysql -h 127.0.0.1 -P 3306 -uapp -papppass rideHailing

# Con root (para administración)
docker exec -it mysql mysql -uroot -prootpass rideHailing
```

## Estructura del proyecto

```
.
├── compose.yml        # Despliegue Docker de MySQL
├── schema.sql         # Creación de la BD, tablas e índices
├── data.sql           # Datos de prueba (carga masiva)
├── queries.sql        # Consultas operativas
├── dashboard.sql      # Consultas para el dashboard de métricas
├── backup.sql         # Plan de backup y recuperación
├── permissions.sql    # Usuarios y permisos de BD
├── README.md          # Este fichero
├── DESIGN.md          # Diseño de la BD con MER en Mermaid
└── presentacion.pdf   # Presentación del proyecto
```

## Ejemplos de consultas básicas

### Ejecutar una consulta concreta

```bash
docker exec -i mysql mysql -uapp -papppass rideHailing < queries.sql
```

### Ejecutar una sola sentencia

```bash
docker exec -it mysql mysql -uapp -papppass rideHailing \
  -e "SELECT * FROM trips WHERE status = 'solicitado';"
```


## Backup y recuperación

Ver `backup.sql` para el plan completo. Resumen rápido:

```bash
# Crear backup
docker exec mysql mysqldump -uroot -prootpass rideHailing > backup_$(date +%F).sql

# Restaurar backup
docker exec -i mysql mysql -uroot -prootpass rideHailing < backup_YYYY-MM-DD.sql
```


## Parar y limpiar

```bash
# Parar contenedores (los datos persisten en el volumen)
docker compose down

# Parar Y borrar todos los datos
docker compose down -v
```


## Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| `Error 1045: Access denied` | Credenciales incorrectas | Comprueba usuario y contraseña |
| `Connection refused` en puerto 3306 | El contenedor no ha arrancado | `docker compose up -d` y espera el healthcheck |
| `Table doesn't exist` al cargar `data.sql` | `schema.sql` no se ha ejecutado antes | Ejecutar pasos en orden |
| El healthcheck no pasa | MySQL tardando en inicializarse | Esperar ~30 s y volver a comprobar con `docker compose ps` |

