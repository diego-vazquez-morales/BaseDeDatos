# DESIGN

> En el siguiente md va encontrar explicadas todas las decisiones de diseño que se tomaron para construir la base de datos para esta practica.

---

## Diagrama de entidad relación

```mermaid
erDiagram
    COMPANY {
        bigint id_company PK
        varchar nombre
        varchar cif UK
        varchar pais
        timestamp creado_en
    }

    USUARIO {
        bigint id_usuario PK
        varchar nombre
        varchar email UK
        varchar telefono UK
        varchar password
        decimal rating
        enum estado
        timestamp creado_en
    }

    RIDER {
        bigint id_rider PK
        bigint id_usuario FK
        enum metodo_pago
        timestamp creado_en
    }

    CONDUCTOR {
        bigint id_conductor PK
        bigint id_usuario FK
        bigint id_company FK
        varchar licensia UK
        decimal valoracion_media
        timestamp creado_en
    }

    VEHICULO {
        bigint id_vehiculo PK
        varchar matricula UK
        varchar marca
        varchar modelo
        year anio
        bigint id_conductor FK
        timestamp creado_en
    }

    TARIFA {
        bigint id_tarifa PK
        bigint id_company FK
        decimal euro_por_km
        decimal euro_por_minuto
        decimal precio_base
        timestamp vigente_desde
    }

    VIAJE {
        bigint id_viaje PK
        bigint id_rider FK
        bigint id_conductor_aceptado FK
        bigint id_tarifa FK
        decimal origen_lat
        decimal origen_lon
        decimal destino_lat
        decimal destino_lon
        decimal distancia_km
        decimal duracion_minutos
        enum estado
        decimal precio_total
        timestamp creado_en
        timestamp actualizado_en
    }

    OFERTA {
        bigint id_oferta PK
        bigint id_viaje FK
        enum estado
        timestamp creado_en
    }

    OFERTA_CONDUCTOR {
        bigint id_oferta PK,FK
        bigint id_conductor PK,FK
        enum decision
        timestamp respondida_en
    }

    VALORACION {
        bigint id_valoracion PK
        bigint id_viaje FK
        bigint id_rider FK
        bigint id_conductor FK
        int puntuacion
        varchar comentario
        timestamp creado_en
    }

    EMPRESA_VEHICULO {
        bigint id_company PK,FK
        bigint id_vehiculo PK,FK
        date fecha_asignacion PK
        date fecha_fin
    }

    EVENTO_VIAJE {
        bigint id_evento PK
        bigint id_viaje FK
        bigint id_rider FK
        bigint id_conductor FK
        enum tipo_evento
        enum estado_anterior
        enum estado_nuevo
        timestamp creado_en
    }

    COMPANY ||--o{ CONDUCTOR : "emplea"
    COMPANY ||--o{ TARIFA : "define"
    COMPANY ||--o{ EMPRESA_VEHICULO : "gestiona"
    CONDUCTOR ||--o{ VEHICULO : "conduce"
    CONDUCTOR ||--o{ OFERTA_CONDUCTOR : "recibe"
    CONDUCTOR ||--o{ EVENTO_VIAJE : "participa"
    RIDER ||--o{ VIAJE : "solicita"
    RIDER ||--o{ VALORACION : "puntua"
    RIDER ||--o{ EVENTO_VIAJE : "origina"
    VIAJE ||--|| OFERTA : "genera"
    VIAJE ||--o| VALORACION : "recibe"
    VIAJE ||--o{ EVENTO_VIAJE : "registra"
    VIAJE }o--|| TARIFA : "aplica"
    OFERTA ||--o{ OFERTA_CONDUCTOR : "enviada a"
    VEHICULO ||--o{ EMPRESA_VEHICULO : "asignado a"
    USUARIO ||--|| RIDER : "es"
    USUARIO ||--|| CONDUCTOR : "es"
```

---

## Que tablas hemos usado y porque

### 1. USUARIO

Esta tabla la hemos creado por que en la plataforma hay dos tipos de usuarios, el rider y el conductor. Ambos comparten varios campos en comun como **nombre, email, telefono y contraseña**. En lugar de repetir estos campos en dos tablas diferentes, hemos implementado **USUARIO**. Tanto Rider como Conductor tienen una relacion `es(1:1)` con Usuario, heredando los campos comunes. Tambien hemos implementado el campo `estado` para poder bloquear o desactivar una cuenta sin borrarla de la base de datos. El campo `rating` representa la puntuación general del usuario.

### 2. RIDER

Esta es una de las tablas principales del sistema, representa a la persona o cliente que solicita un viaje de un punto A a un punto B. Hereda los datos de `Usuario` a traves de `id_usuario` y añade el campo `metodo_pago` que es especifico del Rider quien es el que paga un viaje.

Rider tiene una relación `solicita(1:n)` con `viaje` ya que un **rider** puede realizar múltiples viajes a lo largo del tiempo, guardando en `viaje` el id del rider como clave foránea.

---

### 3. CONDUCTOR

Esta tabla representa al conductor que acepta las ofertas de viajes y lleva al rider a su destino. Al igual que la tabla Rider, esta hereda los datos personales de `Usuario` a través de id_usuario. Añade campos especificos como la licencia de conducir y la valoracion_media que se actualiza cada vez que un rider puntúa un viaje.

Conductor tiene 4 relaciones más:

- Tiene una relación `recibe(N:N)` con Oferta ya que una oferta puede ser enviada a muchos conductores y un conductor puede recibir muchas ofertas.
- Tiene una relación `conduce(1:N)` con vehículo ya que un conductor puede tener varios vehiculos asignados a lo largo del tiempo.
- Tiene una relacion con Viaje en donde guardamos el id del conductor que aceptó la oferta en el campo `id_conductor_aceptado`.
- Pertenece a una Company y guarda el `id_company` como clave foránea.

---

### 4. COMPANY

Esta tabla respresenta las empresas. Existe por que todos los conductores tienen que pertenecer a una empresa. En esta guardamos el nombre, CIF, y país de origen de la compañía. Tiene una relación con Vehículo por que en este tipo de plataformas los coches suelen ser propiedad de las empresas, no de los conductores, esto esta representado en la tabla intermedia `empresa_vehiculo`.  

---

### 5. VEHÍCULO

Los conductores necesitan un vehículo para transportar a los riders. La relación entre conductor y vehículo es `(1:N)` ya que un conductor puede tener varios vehículos asignados a lo largo del tiempo. Adicionalmente está relacionado con `Company` a través de `empresa_vehiculo` porque el vehículo pertenece a la empresa.

---

### 6. TARIFA

Esta tabla ha sido creada con el motivo de tener los precios separados del resto del sistema. Cada **Company** define su propia tarifa con tres componentes: un `precio_base` fijo al inicio de cada viaje, un coste por kilómetro y un coste por minuto. La relación con **Company** es `(1:N)` ya que un **Company** puede tener múltiples tarifas a lo largo del tiempo debido al campo `vigente_desde`. Esto permite tener un historial de los precios y los cambios que se hagan a lo largo del tiempo sin afectar viajes que ya se hayan realizados. Cada viaje referencia la tarifa que esta vigente en el momento de su creación. 

---

### 7. VIAJE

`Viaje` es la entidad central del sistema, representa el trayecto solicitado por un rider de un punto A a un punto B. La hemos creado para registrar toda la información del trayecto: coordenadas, estado, duración, distancia y precio final, siendo el nexo entre el rider, el conductor y la tarifa aplicada.

---

### 8. OFERTA

Cuando un rider solicita un viaje el sistema genera una oferta que se envía a todos los conductores activos. En esta tabla guardamos el estado de esa oferta y el viaje al que pertenece. La relación con **Viaje** es `(1:1)` ya que cada viaje genera exactamente una oferta.

---

### 9. OFERTA_CONDUCTOR

Esta es la tabla intermedia que resulta de la relación `(N:N)` entre oferta y conductor. Cuando un rider solicita un viaje, el sistema crea una oferta y la envia a todos los conductores que esten activos, insertando una fila en esa tabla por cada condcutor con el campo `decision = 'pendiente'`. El primer conductor que acepta la oferta, inicia una transacción que actualiza su fila en el campo de `decision` a `decision = 'aceptada'`, se rechaza automáticamente al resto. Para poder garantizar que nunca haya dos conductores con el campo `decision = 'aceptada'` para una misma oferta, hemos implementado un trigger BEFORE UPDATE, este lanza un error si se intenta aceptar una oferta que ya ha sido aceptada previamente. 

---

### 10. VALORACION

Esta tabla recoge la puntuacion que un rider le da a un conductor tras finalizar un viaje. La relacion con viaje tiene un `UNIQUE KEY` sobre `id_viaje` garantizando que sólo puede existir una valoración por viaje. La puntuación está entre un rango entre 1 y 5 mediante un `CHECK constraint`. Tras cada inserción de valoración, se actualiza el campo de `valoracion_media` del cconductor correspondiente. La tabla también indexa `id_conductor` e `id_rider` para acelerar las consultas de métricas de rendimiento por **Conductor** y por **Company**.

---

### 11. EMPRESA_VEHICULO

Esta tabla resulta de la relacion N:N entre company y vehiculo. Un vehiculo puede estar asignado a diferentes empresas a lo largo del tiempo y una empresa puede gestionar multiples vehiculos simultaneamente. La Primary Key esta compuesta por id_company, id_vehiculo y fecha_asignacion, esto permite registrar reasignaciones que puedan haber a lo largo del tiempo sin perder un historial. Cuando el campo fecha_fin es NULL, quiere decir que la asignacion esta vigente actualmente, esto permite filtrar de forma facil y rapida los vehiculos que hay activos en las empresas.

---

## Historial y auditoría

Para cubrir el requisito de historial y auditoría básica de operaciones hemos creado la tabla `evento_viaje`, que actúa como un log inmutable de todos los cambios de estado de cada viaje. Cada vez que un viaje transiciona de estado se inserta una fila nueva con el estado anterior, el estado nuevo, el actor responsable (rider o conductor) y el timestamp exacto. Esto nos permite reconstruir la línea de tiempo completa de cualquier viaje y detectar anomalías como viajes que nunca salen de `solicitado` o cancelaciones repetidas de un mismo rider.

## ÍNDICES

Adicional a los índices que crea MySQL para las claves primarias y únicas, hemos optado por implementar índices adicionales en las columnas que pueden ser mas usadas en consultas para filtrar, joins y ordenar. 

- `idx_viaje_estado`: para filtrar viajes por estado, que es la operación más frecuente en la operativa del sistema.
- `idx_viaje_rider`: para consultar el historial de viajes de un rider concreto.
- `idx_viaje_conductor_aceptado`: para buscar los viajes de un condcutor.
- `idx_viaje_creado_en`: para filtrar y ordenar por fecha.
- `idx_valoracion_conductor`: para calcular la valoración media de un conductor sin calcular sobre toda la tabla. 
- `idx_valoracion_rider`: para consultar el historial de valoraciones de un rider.
- `idx_evento_viaje`: para recuperar todos los eventos de un viaje específico.

## Triggers

Hemos implementado dos triggers en el sistema:

-# DESIGN

> En el siguiente md va encontrar explicadas todas las decisiones de diseño que se tomaron para construir la base de datos para esta practica.

---

## Diagrama de entidad relación

```mermaid
erDiagram
    COMPANY {
        bigint id_company PK
        varchar nombre
        varchar cif UK
        varchar pais
        timestamp creado_en
    }

    USUARIO {
        bigint id_usuario PK
        varchar nombre
        varchar email UK
        varchar telefono UK
        varchar password
        decimal rating
        enum estado
        timestamp creado_en
    }

    RIDER {
        bigint id_rider PK
        bigint id_usuario FK
        enum metodo_pago
        timestamp creado_en
    }

    CONDUCTOR {
        bigint id_conductor PK
        bigint id_usuario FK
        bigint id_company FK
        varchar licensia UK
        decimal valoracion_media
        timestamp creado_en
    }

    VEHICULO {
        bigint id_vehiculo PK
        varchar matricula UK
        varchar marca
        varchar modelo
        year anio
        bigint id_conductor FK
        timestamp creado_en
    }

    TARIFA {
        bigint id_tarifa PK
        bigint id_company FK
        decimal euro_por_km
        decimal euro_por_minuto
        decimal precio_base
        timestamp vigente_desde
    }

    VIAJE {
        bigint id_viaje PK
        bigint id_rider FK
        bigint id_conductor_aceptado FK
        bigint id_tarifa FK
        decimal origen_lat
        decimal origen_lon
        decimal destino_lat
        decimal destino_lon
        decimal distancia_km
        decimal duracion_minutos
        enum estado
        decimal precio_total
        timestamp creado_en
        timestamp actualizado_en
    }

    OFERTA {
        bigint id_oferta PK
        bigint id_viaje FK
        enum estado
        timestamp creado_en
    }

    OFERTA_CONDUCTOR {
        bigint id_oferta PK,FK
        bigint id_conductor PK,FK
        enum decision
        timestamp respondida_en
    }

    VALORACION {
        bigint id_valoracion PK
        bigint id_viaje FK
        bigint id_rider FK
        bigint id_conductor FK
        int puntuacion
        varchar comentario
        timestamp creado_en
    }

    EMPRESA_VEHICULO {
        bigint id_company PK,FK
        bigint id_vehiculo PK,FK
        date fecha_asignacion PK
        date fecha_fin
    }

    EVENTO_VIAJE {
        bigint id_evento PK
        bigint id_viaje FK
        bigint id_rider FK
        bigint id_conductor FK
        enum tipo_evento
        enum estado_anterior
        enum estado_nuevo
        timestamp creado_en
    }

    COMPANY ||--o{ CONDUCTOR : "emplea"
    COMPANY ||--o{ TARIFA : "define"
    COMPANY ||--o{ EMPRESA_VEHICULO : "gestiona"
    CONDUCTOR ||--o{ VEHICULO : "conduce"
    CONDUCTOR ||--o{ OFERTA_CONDUCTOR : "recibe"
    CONDUCTOR ||--o{ EVENTO_VIAJE : "participa"
    RIDER ||--o{ VIAJE : "solicita"
    RIDER ||--o{ VALORACION : "puntua"
    RIDER ||--o{ EVENTO_VIAJE : "origina"
    VIAJE ||--|| OFERTA : "genera"
    VIAJE ||--o| VALORACION : "recibe"
    VIAJE ||--o{ EVENTO_VIAJE : "registra"
    VIAJE }o--|| TARIFA : "aplica"
    OFERTA ||--o{ OFERTA_CONDUCTOR : "enviada a"
    VEHICULO ||--o{ EMPRESA_VEHICULO : "asignado a"
    USUARIO ||--|| RIDER : "es"
    USUARIO ||--|| CONDUCTOR : "es"
```

---

## Que tablas hemos usado y porque

### 1. USUARIO

Esta tabla la hemos creado por que en la plataforma hay dos tipos de usuarios, el rider y el conductor. Ambos comparten varios campos en comun como **nombre, email, telefono y contraseña**. En lugar de repetir estos campos en dos tablas diferentes, hemos implementado **USUARIO**. Tanto Rider como Conductor tienen una relacion `es(1:1)` con Usuario, heredando los campos comunes. Tambien hemos implementado el campo `estado` para poder bloquear o desactivar una cuenta sin borrarla de la base de datos. El campo `rating` representa la puntuación general del usuario.

### 2. RIDER

Esta es una de las tablas principales del sistema, representa a la persona o cliente que solicita un viaje de un punto A a un punto B. Hereda los datos de `Usuario` a traves de `id_usuario` y añade el campo `metodo_pago` que es especifico del Rider quien es el que paga un viaje.

Rider tiene una relación `solicita(1:n)` con `viaje` ya que un **rider** puede realizar múltiples viajes a lo largo del tiempo, guardando en `viaje` el id del rider como clave foránea.

---

### 3. CONDUCTOR

Esta tabla representa al conductor que acepta las ofertas de viajes y lleva al rider a su destino. Al igual que la tabla Rider, esta hereda los datos personales de `Usuario` a través de id_usuario. Añade campos especificos como la licencia de conducir y la valoracion_media que se actualiza cada vez que un rider puntúa un viaje.

Conductor tiene 4 relaciones más:

- Tiene una relación `recibe(N:N)` con Oferta ya que una oferta puede ser enviada a muchos conductores y un conductor puede recibir muchas ofertas.
- Tiene una relación `conduce(1:N)` con vehículo ya que un conductor puede tener varios vehiculos asignados a lo largo del tiempo.
- Tiene una relacion con Viaje en donde guardamos el id del conductor que aceptó la oferta en el campo `id_conductor_aceptado`.
- Pertenece a una Company y guarda el `id_company` como clave foránea.

---

### 4. COMPANY

Esta tabla respresenta las empresas. Existe por que todos los conductores tienen que pertenecer a una empresa. En esta guardamos el nombre, CIF, y país de origen de la compañía. Tiene una relación con Vehículo por que en este tipo de plataformas los coches suelen ser propiedad de las empresas, no de los conductores, esto esta representado en la tabla intermedia `empresa_vehiculo`.  

---

### 5. VEHÍCULO

Los conductores necesitan un vehículo para transportar a los riders. La relación entre conductor y vehículo es `(1:N)` ya que un conductor puede tener varios vehículos asignados a lo largo del tiempo. Adicionalmente está relacionado con `Company` a través de `empresa_vehiculo` porque el vehículo pertenece a la empresa.

---

### 6. TARIFA

Esta tabla ha sido creada con el motivo de tener los precios separados del resto del sistema. Cada **Company** define su propia tarifa con tres componentes: un `precio_base` fijo al inicio de cada viaje, un coste por kilómetro y un coste por minuto. La relación con **Company** es `(1:N)` ya que un **Company** puede tener múltiples tarifas a lo largo del tiempo debido al campo `vigente_desde`. Esto permite tener un historial de los precios y los cambios que se hagan a lo largo del tiempo sin afectar viajes que ya se hayan realizados. Cada viaje referencia la tarifa que esta vigente en el momento de su creación. 

---

### 7. VIAJE

`Viaje` es la entidad central del sistema, representa el trayecto solicitado por un rider de un punto A a un punto B. La hemos creado para registrar toda la información del trayecto: coordenadas, estado, duración, distancia y precio final, siendo el nexo entre el rider, el conductor y la tarifa aplicada.

---

### 8. OFERTA

Cuando un rider solicita un viaje el sistema genera una oferta que se envía a todos los conductores activos. En esta tabla guardamos el estado de esa oferta y el viaje al que pertenece. La relación con **Viaje** es `(1:1)` ya que cada viaje genera exactamente una oferta.

---

### 9. OFERTA_CONDUCTOR

Esta es la tabla intermedia que resulta de la relación `(N:N)` entre oferta y conductor. Cuando un rider solicita un viaje, el sistema crea una oferta y la envia a todos los conductores que esten activos, insertando una fila en esa tabla por cada condcutor con el campo `decision = 'pendiente'`. El primer conductor que acepta la oferta, inicia una transacción que actualiza su fila en el campo de `decision` a `decision = 'aceptada'`, se rechaza automáticamente al resto. Para poder garantizar que nunca haya dos conductores con el campo `decision = 'aceptada'` para una misma oferta, hemos implementado un trigger BEFORE UPDATE, este lanza un error si se intenta aceptar una oferta que ya ha sido aceptada previamente. 

---

### 10. VALORACION

Esta tabla recoge la puntuacion que un rider le da a un conductor tras finalizar un viaje. La relacion con viaje tiene un `UNIQUE KEY` sobre `id_viaje` garantizando que sólo puede existir una valoración por viaje. La puntuación está entre un rango entre 1 y 5 mediante un `CHECK constraint`. Tras cada inserción de valoración, se actualiza el campo de `valoracion_media` del cconductor correspondiente. La tabla también indexa `id_conductor` e `id_rider` para acelerar las consultas de métricas de rendimiento por **Conductor** y por **Company**.

---

### 11. EMPRESA_VEHICULO

Esta tabla resulta de la relacion N:N entre company y vehiculo. Un vehiculo puede estar asignado a diferentes empresas a lo largo del tiempo y una empresa puede gestionar multiples vehiculos simultaneamente. La Primary Key esta compuesta por id_company, id_vehiculo y fecha_asignacion, esto permite registrar reasignaciones que puedan haber a lo largo del tiempo sin perder un historial. Cuando el campo fecha_fin es NULL, quiere decir que la asignacion esta vigente actualmente, esto permite filtrar de forma facil y rapida los vehiculos que hay activos en las empresas.

---

## Historial y auditoría

Para cubrir el requisito de historial y auditoría básica de operaciones hemos creado la tabla `evento_viaje`, que actúa como un log inmutable de todos los cambios de estado de cada viaje. Cada vez que un viaje transiciona de estado se inserta una fila nueva con el estado anterior, el estado nuevo, el actor responsable (rider o conductor) y el timestamp exacto. Esto nos permite reconstruir la línea de tiempo completa de cualquier viaje y detectar anomalías como viajes que nunca salen de `solicitado` o cancelaciones repetidas de un mismo rider.

## ÍNDICES

Adicional a los índices que crea MySQL para las claves primarias y únicas, hemos optado por implementar índices adicionales en las columnas que pueden ser mas usadas en consultas para filtrar, joins y ordenar. 

- `idx_viaje_estado`: para filtrar viajes por estado, que es la operación más frecuente en la operativa del sistema.
- `idx_viaje_rider`: para consultar el historial de viajes de un rider concreto.
- `idx_viaje_conductor_aceptado`: para buscar los viajes de un condcutor.
- `idx_viaje_creado_en`: para filtrar y ordenar por fecha.
- `idx_valoracion_conductor`: para calcular la valoración media de un conductor sin calcular sobre toda la tabla. 
- `idx_valoracion_rider`: para consultar el historial de valoraciones de un rider.
- `idx_evento_viaje`: para recuperar todos los eventos de un viaje específico.

## Triggers

Hemos implementado dos triggers en el sistema:
trg# DESIGN

> En el siguiente md va encontrar explicadas todas las decisiones de diseño que se tomaron para construir la base de datos para esta practica.

---

## Diagrama de entidad relación

```mermaid
erDiagram
    COMPANY {
        bigint id_company PK
        varchar nombre
        varchar cif UK
        varchar pais
        timestamp creado_en
    }

    USUARIO {
        bigint id_usuario PK
        varchar nombre
        varchar email UK
        varchar telefono UK
        varchar password
        decimal rating
        enum estado
        timestamp creado_en
    }

    RIDER {
        bigint id_rider PK
        bigint id_usuario FK
        enum metodo_pago
        timestamp creado_en
    }

    CONDUCTOR {
        bigint id_conductor PK
        bigint id_usuario FK
        bigint id_company FK
        varchar licensia UK
        decimal valoracion_media
        timestamp creado_en
    }

    VEHICULO {
        bigint id_vehiculo PK
        varchar matricula UK
        varchar marca
        varchar modelo
        year anio
        bigint id_conductor FK
        timestamp creado_en
    }

    TARIFA {
        bigint id_tarifa PK
        bigint id_company FK
        decimal euro_por_km
        decimal euro_por_minuto
        decimal precio_base
        timestamp vigente_desde
    }

    VIAJE {
        bigint id_viaje PK
        bigint id_rider FK
        bigint id_conductor_aceptado FK
        bigint id_tarifa FK
        decimal origen_lat
        decimal origen_lon
        decimal destino_lat
        decimal destino_lon
        decimal distancia_km
        decimal duracion_minutos
        enum estado
        decimal precio_total
        timestamp creado_en
        timestamp actualizado_en
    }

    OFERTA {
        bigint id_oferta PK
        bigint id_viaje FK
        enum estado
        timestamp creado_en
    }

    OFERTA_CONDUCTOR {
        bigint id_oferta PK,FK
        bigint id_conductor PK,FK
        enum decision
        timestamp respondida_en
    }

    VALORACION {
        bigint id_valoracion PK
        bigint id_viaje FK
        bigint id_rider FK
        bigint id_conductor FK
        int puntuacion
        varchar comentario
        timestamp creado_en
    }

    EMPRESA_VEHICULO {
        bigint id_company PK,FK
        bigint id_vehiculo PK,FK
        date fecha_asignacion PK
        date fecha_fin
    }

    EVENTO_VIAJE {
        bigint id_evento PK
        bigint id_viaje FK
        bigint id_rider FK
        bigint id_conductor FK
        enum tipo_evento
        enum estado_anterior
        enum estado_nuevo
        timestamp creado_en
    }

    COMPANY ||--o{ CONDUCTOR : "emplea"
    COMPANY ||--o{ TARIFA : "define"
    COMPANY ||--o{ EMPRESA_VEHICULO : "gestiona"
    CONDUCTOR ||--o{ VEHICULO : "conduce"
    CONDUCTOR ||--o{ OFERTA_CONDUCTOR : "recibe"
    CONDUCTOR ||--o{ EVENTO_VIAJE : "participa"
    RIDER ||--o{ VIAJE : "solicita"
    RIDER ||--o{ VALORACION : "puntua"
    RIDER ||--o{ EVENTO_VIAJE : "origina"
    VIAJE ||--|| OFERTA : "genera"
    VIAJE ||--o| VALORACION : "recibe"
    VIAJE ||--o{ EVENTO_VIAJE : "registra"
    VIAJE }o--|| TARIFA : "aplica"
    OFERTA ||--o{ OFERTA_CONDUCTOR : "enviada a"
    VEHICULO ||--o{ EMPRESA_VEHICULO : "asignado a"
    USUARIO ||--|| RIDER : "es"
    USUARIO ||--|| CONDUCTOR : "es"
```

---

## Que tablas hemos usado y porque

### 1. USUARIO

Esta tabla la hemos creado por que en la plataforma hay dos tipos de usuarios, el rider y el conductor. Ambos comparten varios campos en comun como **nombre, email, telefono y contraseña**. En lugar de repetir estos campos en dos tablas diferentes, hemos implementado **USUARIO**. Tanto Rider como Conductor tienen una relacion `es(1:1)` con Usuario, heredando los campos comunes. Tambien hemos implementado el campo `estado` para poder bloquear o desactivar una cuenta sin borrarla de la base de datos. El campo `rating` representa la puntuación general del usuario.

### 2. RIDER

Esta es una de las tablas principales del sistema, representa a la persona o cliente que solicita un viaje de un punto A a un punto B. Hereda los datos de `Usuario` a traves de `id_usuario` y añade el campo `metodo_pago` que es especifico del Rider quien es el que paga un viaje.

Rider tiene una relación `solicita(1:n)` con `viaje` ya que un **rider** puede realizar múltiples viajes a lo largo del tiempo, guardando en `viaje` el id del rider como clave foránea.

---

### 3. CONDUCTOR

Esta tabla representa al conductor que acepta las ofertas de viajes y lleva al rider a su destino. Al igual que la tabla Rider, esta hereda los datos personales de `Usuario` a través de id_usuario. Añade campos especificos como la licencia de conducir y la valoracion_media que se actualiza cada vez que un rider puntúa un viaje.

Conductor tiene 4 relaciones más:

- Tiene una relación `recibe(N:N)` con Oferta ya que una oferta puede ser enviada a muchos conductores y un conductor puede recibir muchas ofertas.
- Tiene una relación `conduce(1:N)` con vehículo ya que un conductor puede tener varios vehiculos asignados a lo largo del tiempo.
- Tiene una relacion con Viaje en donde guardamos el id del conductor que aceptó la oferta en el campo `id_conductor_aceptado`.
- Pertenece a una Company y guarda el `id_company` como clave foránea.

---

### 4. COMPANY

Esta tabla respresenta las empresas. Existe por que todos los conductores tienen que pertenecer a una empresa. En esta guardamos el nombre, CIF, y país de origen de la compañía. Tiene una relación con Vehículo por que en este tipo de plataformas los coches suelen ser propiedad de las empresas, no de los conductores, esto esta representado en la tabla intermedia `empresa_vehiculo`.  

---

### 5. VEHÍCULO

Los conductores necesitan un vehículo para transportar a los riders. La relación entre conductor y vehículo es `(1:N)` ya que un conductor puede tener varios vehículos asignados a lo largo del tiempo. Adicionalmente está relacionado con `Company` a través de `empresa_vehiculo` porque el vehículo pertenece a la empresa.

---

### 6. TARIFA

Esta tabla ha sido creada con el motivo de tener los precios separados del resto del sistema. Cada **Company** define su propia tarifa con tres componentes: un `precio_base` fijo al inicio de cada viaje, un coste por kilómetro y un coste por minuto. La relación con **Company** es `(1:N)` ya que un **Company** puede tener múltiples tarifas a lo largo del tiempo debido al campo `vigente_desde`. Esto permite tener un historial de los precios y los cambios que se hagan a lo largo del tiempo sin afectar viajes que ya se hayan realizados. Cada viaje referencia la tarifa que esta vigente en el momento de su creación. 

---

### 7. VIAJE

`Viaje` es la entidad central del sistema, representa el trayecto solicitado por un rider de un punto A a un punto B. La hemos creado para registrar toda la información del trayecto: coordenadas, estado, duración, distancia y precio final, siendo el nexo entre el rider, el conductor y la tarifa aplicada.

---

### 8. OFERTA

Cuando un rider solicita un viaje el sistema genera una oferta que se envía a todos los conductores activos. En esta tabla guardamos el estado de esa oferta y el viaje al que pertenece. La relación con **Viaje** es `(1:1)` ya que cada viaje genera exactamente una oferta.

---

### 9. OFERTA_CONDUCTOR

Esta es la tabla intermedia que resulta de la relación `(N:N)` entre oferta y conductor. Cuando un rider solicita un viaje, el sistema crea una oferta y la envia a todos los conductores que esten activos, insertando una fila en esa tabla por cada condcutor con el campo `decision = 'pendiente'`. El primer conductor que acepta la oferta, inicia una transacción que actualiza su fila en el campo de `decision` a `decision = 'aceptada'`, se rechaza automáticamente al resto. Para poder garantizar que nunca haya dos conductores con el campo `decision = 'aceptada'` para una misma oferta, hemos implementado un trigger BEFORE UPDATE, este lanza un error si se intenta aceptar una oferta que ya ha sido aceptada previamente. 

---

### 10. VALORACION

Esta tabla recoge la puntuacion que un rider le da a un conductor tras finalizar un viaje. La relacion con viaje tiene un `UNIQUE KEY` sobre `id_viaje` garantizando que sólo puede existir una valoración por viaje. La puntuación está entre un rango entre 1 y 5 mediante un `CHECK constraint`. Tras cada inserción de valoración, se actualiza el campo de `valoracion_media` del cconductor correspondiente. La tabla también indexa `id_conductor` e `id_rider` para acelerar las consultas de métricas de rendimiento por **Conductor** y por **Company**.

---

### 11. EMPRESA_VEHICULO

Esta tabla resulta de la relacion N:N entre company y vehiculo. Un vehiculo puede estar asignado a diferentes empresas a lo largo del tiempo y una empresa puede gestionar multiples vehiculos simultaneamente. La Primary Key esta compuesta por id_company, id_vehiculo y fecha_asignacion, esto permite registrar reasignaciones que puedan haber a lo largo del tiempo sin perder un historial. Cuando el campo fecha_fin es NULL, quiere decir que la asignacion esta vigente actualmente, esto permite filtrar de forma facil y rapida los vehiculos que hay activos en las empresas.

---

## Historial y auditoría

Para cubrir el requisito de historial y auditoría básica de operaciones hemos creado la tabla `evento_viaje`, que actúa como un log inmutable de todos los cambios de estado de cada viaje. Cada vez que un viaje transiciona de estado se inserta una fila nueva con el estado anterior, el estado nuevo, el actor responsable (rider o conductor) y el timestamp exacto. Esto nos permite reconstruir la línea de tiempo completa de cualquier viaje y detectar anomalías como viajes que nunca salen de `solicitado` o cancelaciones repetidas de un mismo rider.

## ÍNDICES

Adicional a los índices que crea MySQL para las claves primarias y únicas, hemos optado por implementar índices adicionales en las columnas que pueden ser mas usadas en consultas para filtrar, joins y ordenar. 

- `idx_viaje_estado`: para filtrar viajes por estado, que es la operación más frecuente en la operativa del sistema.
- `idx_viaje_rider`: para consultar el historial de viajes de un rider concreto.
- `idx_viaje_conductor_aceptado`: para buscar los viajes de un condcutor.
- `idx_viaje_creado_en`: para filtrar y ordenar por fecha.
- `idx_valoracion_conductor`: para calcular la valoración media de un conductor sin calcular sobre toda la tabla. 
- `idx_valoracion_rider`: para consultar el historial de valoraciones de un rider.
- `idx_evento_viaje`: para recuperar todos los eventos de un viaje específico.

## Triggers

Hemos implementado dos triggers en el sistema:
- `trg_viaje_update`: se ejecuta antes de cualquier consulta UPDATE en la tabla **Viaje** y actualiza el campo `actualizado_en` con el timestamp actual. Así siempre sabemos cuándo fue la última vez que se modificó un viaje sin tener que hacerlo manualmente en cada query.

- `trg_oferta_conductor_unica_aceptacion`: se ejecuta antes de cualquier consulta UPDATE en `oferta_conductor`. Si alguien intenta poner - `decision = 'aceptada'` en una oferta que ya tiene otro conductor con ese campo, el trigger lanza un error y la operación se cancela. Esto garantiza que nunca haya dos conductores aceptando el mismo viaje al mismo tiempo. 

## Concurrencia

Uno de los aspectos mas importantes del sistema es que se pueda garantizar que cuando varios conductores intentan aceptar la misma oferta al mismo tiempo, solo uno de ellos pueden quedar con esta. Para resolver esto usamos **SELECT ... FOR UPDATE** dentro de una transaccion antes de actualizar la decision del conductor. 
Lo que hace FOR UPDATE es bloquear la fila de ese conductor en la tabla `oferta_conductor` para que ninguna otra sesion pueda modificarla hasta que termine la transaccion. Si dos conductores intentan aceptar la misma oferta al mismo tiempo, el segundo tendra que esperar a que el primero termine y cuando sea su turno vera que la oferta ya ha sido aceptada.
