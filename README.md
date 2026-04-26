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
type schema.sql | docker exec -i mysql mysql -uroot -prootpass

```

### 3. Cargar los datos de prueba

```bash
type data.sql | docker exec -i mysql mysql -uroot -prootpass

```

### 4. Aplicar permisos

```bash
type permissions.sql | docker exec -i mysql mysql -uroot -prootpass

```

### 5. (Opcional) Cargar consultas del dashboard

```bash
type dashboard.sql | docker exec -i mysql mysql -uroot -prootpass

```
Para acceder a grafana debemos:
1. Acceder http://localhost:3000/
2. Usuario: admin Contraseña: Admin
3. Si es la primera conexion entonces ir a Add new connection
4. Seleccionar Prometheus con conexion: http://prometheus:9090 y lo guardas
5. Ir a dashboard e importar el 14057
6. Despues de importar el 14057 aparece una opcion de UID que hay que cambiar por "prometheus"
7. Tras eso lo importas y ya te aparecen las metricas de grafana

Cabe aclarar que grafana lo que muestra son metricas del sistema recogidas automaticamente por el exporter, pero no van enlazadas con las de nuestro dashboard.sql que aunque hay metricas parecidas no todas son compartidas y el dashboard.sql debe ejecutarse tambien para tener en cuenta mas metricas del sistema y del negocio.

### 6. Ejecutar  el backup

```bash
bash backup.sh # para hacer backup unico a mano 

0 * * * * cd "/ruta/BaseDeDatos" && bash backup.sh >> backup.log 2>&1   #para ejecutar un backup automatico en cada hora EN LINUX

#Para ejecutar en windows podemos acceder a git bash y poner que se ejecute cada x tiempo que añamos definido nosotros:
while true
do
    bash backup.sh
    sleep 3600 #cantidad de segundos que tiene una hora
done


```
### 7.Restaurar el backup
```bash
docker exec -i mysql mysql -uroot -prootpass < backup_FECHA.sql

```
### 7.1 Restaurar backup con PITR (binlog)
```bash
docker exec -i mysql mysql -uroot -prootpass < backup_FECHA.sql

docker exec mysql mysqlbinlog \
--        --start-datetime="año-mes-dia hora:minuto:segundos" \ #hora de inicio
--        --stop-datetime="año-mes-dia hora:minuto:segundos" \ #hora de fin
--        /var/lib/mysql/binlog.000001 > cambios.sql

docker exec -i mysql mysql -uroot -prootpass < cambios.sql
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

