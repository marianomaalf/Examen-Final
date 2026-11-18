# Clínica Veterinaria — Migración de TXT a MySQL

Examen Final EIF206 – Programación III. Aplicación Java Swing cuya persistencia se migró de archivos TXT a MySQL usando procedimientos almacenados y JDBC, sin cambiar la vista, el servicio ni los modelos.

Arquitectura: `Main → Vista Swing → Controller → Service → interfaces Repository → RepositorioClienteMySQL / RepositorioMascotaMySQL → procedimientos almacenados`.

## Modelo relacional

| Tabla | Clave primaria | Campos |
|---|---|---|
| `cliente` | `cedula` VARCHAR(20) | `nombre` VARCHAR(80), `telefono` VARCHAR(20) — todos NOT NULL |
| `mascota` | `codigo` VARCHAR(15) | `nombre` VARCHAR(80), `especie` ENUM('PERRO','GATO','OTRO'), `edad` INT, `cedula_cliente` VARCHAR(20) — todos NOT NULL |

**Relación 1:N:** un cliente puede tener varias mascotas y cada mascota pertenece a un único cliente.
`mascota.cedula_cliente` es **clave foránea** hacia `cliente.cedula` con `ON DELETE RESTRICT`, por lo que no se puede registrar una mascota con un dueño inexistente ni eliminar un cliente que tenga mascotas.
Los datos del cliente (nombre, teléfono) se guardan solo en `cliente`; la mascota únicamente referencia la cédula (normalización: separación de entidades, sin datos repetidos).

Restricciones `CHECK`: código, cédula, nombre y teléfono no pueden estar vacíos; `edad` entre 0 y 40, coherente con la validación del modelo `Mascota` y con los datos de ejemplo (edades 1, 3 y 5).

## Procedimientos almacenados

| Procedimiento | Uso en Java |
|---|---|
| `sp_listar_clientes()` | `RepositorioCliente.cargarTodos()` |
| `sp_insertar_cliente(cedula, nombre, telefono)` | `RepositorioCliente.insertar()` |
| `sp_listar_mascotas()` | `RepositorioMascota.cargarTodos()` |
| `sp_insertar_mascota(codigo, nombre, especie, edad, cedula)` | `RepositorioMascota.insertar()` |
| `sp_actualizar_mascota(codigo, nombre, especie, edad, cedula)` | `RepositorioMascota.actualizar()` |
| `sp_eliminar_mascota(codigo)` | `RepositorioMascota.eliminar()` |
| `sp_listar_mascotas_con_dueno()` | `RepositorioMascota.listarConDueno()` (INNER JOIN) |

Todos usan `SQL SECURITY DEFINER` con `DEFINER = vet_definer@localhost`.

## Cuentas y privilegios

| Usuario | Permisos |
|---|---|
| `vet_definer` | SELECT, INSERT sobre `veterinaria.cliente`; SELECT, INSERT, UPDATE, DELETE sobre `veterinaria.mascota`; EXECUTE sobre los 7 procedimientos (MySQL lo requiere para el contexto DEFINER) |
| `vet_app` | Solo EXECUTE sobre los 7 procedimientos. Sin privilegios directos sobre las tablas. Es la cuenta usada desde Java |

La aplicación nunca usa `root`.

## 1. Ejecutar el script SQL

1. Abrir `database/01_veterinaria.sql` en MySQL Workbench con una cuenta administradora.
2. **Reemplazar localmente** `<<CONTRASENA_VET_DEFINER>>` y `<<CONTRASENA_VET_APP>>` por contraseñas seguras y distintas. **No guardar ni subir el archivo con las contraseñas reales.**
3. Ejecutar todo el script (rayo ⚡). Crea la base `veterinaria`, las tablas, los usuarios, los procedimientos y los GRANT, y al final muestra `SHOW GRANTS` de ambos usuarios.

## 2. Configurar variables de entorno

Java lee la configuración con `System.getenv(...)`. El archivo `.env.example` es solo una plantilla; Java **no** lo carga.

En IntelliJ: *Run → Edit Configurations → Main → Environment variables*:

```
VET_DB_URL=jdbc:mysql://localhost:3306/veterinaria?serverTimezone=UTC
VET_DB_USER=vet_app
VET_DB_PASSWORD=<contraseña local de vet_app>
```

## 3. Abrir la aplicación

1. Abrir el proyecto en IntelliJ (Maven descarga `mysql-connector-j`).
2. Ejecutar `examen.veterinaria.Main` con la configuración anterior.
3. Si falta una variable de entorno o falla la conexión, la aplicación muestra un mensaje claro sin cerrarse.

Los datos de ejemplo (2 clientes, 3 mascotas) se cargan con `database/02_pruebas_seguridad.sql` o desde la interfaz.

## 4. Pruebas de seguridad

Abrir en Workbench una conexión con el usuario **`vet_app`** y ejecutar `database/02_pruebas_seguridad.sql`.

| # | Prueba | Resultado esperado |
|---|---|---|
| 1 | `CALL sp_listar_mascotas();` | Devuelve las mascotas ✅ |
| 2 | `SELECT * FROM mascota;` | `Error 1142: SELECT command denied to user 'vet_app'` ❌ |
| 3 | `DELETE FROM mascota WHERE codigo='M01';` | `Error 1142: DELETE command denied` ❌ |
| 4 | `CALL sp_insertar_cliente('101110111', ...)` (duplicado) | `Ya existe un cliente con esa cédula.` |
| 5 | `CALL sp_insertar_mascota('M99', ..., '999999999')` | `El cliente dueño no existe.` |
| 6 | `SHOW GRANTS;` | Solo `EXECUTE` sobre los 7 procedimientos |

## Pruebas funcionales desde la interfaz

- Registrar un cliente y una mascota, cerrar y volver a abrir la app: los datos persisten.
- Actualizar y eliminar una mascota por código; filtrar mascotas por cédula.
- Intentar registrar una cédula o un código repetido, o una mascota con un dueño inexistente: se muestra un mensaje de error.
