-- =====================================================================
-- Pruebas de seguridad y funcionales.
-- EJECUTAR CONECTADO COMO vet_app (NO como root).
-- En Workbench: crear una conexión con usuario vet_app y abrir este script.
-- Ojo: varias pruebas fallan a propósito, así que conviene ir línea por
-- línea con Ctrl+Enter en vez de correr todo el script de una vez.
-- =====================================================================

USE veterinaria;


-- 1) Carga de datos de ejemplo mediante procedimientos (debe funcionar)
-- Son los mismos 2 clientes y 3 mascotas que venían en los archivos TXT.
-- Las edades originales (3, 5 y 1) se ajustaron al rango 18-60 que pide el
-- enunciado; con las originales la base las rechaza (ver prueba 7).
-- Si ya se habían cargado antes, van a salir errores de duplicado y está bien.

CALL sp_insertar_cliente('101110111', 'Ana Mora', '88881111');
CALL sp_insertar_cliente('202220222', 'Luis Solis', '87772222');
CALL sp_insertar_mascota('M01', 'Luna', 'GATO', 18, '101110111');
CALL sp_insertar_mascota('M02', 'Rocky', 'PERRO', 20, '202220222');
CALL sp_insertar_mascota('M03', 'Nina', 'PERRO', 19, '101110111');


-- 2) PRUEBA DE SEGURIDAD: vet_app SÍ puede ejecutar procedimientos
-- Aunque vet_app no tiene permisos sobre las tablas, los procedimientos
-- corren con los permisos de vet_definer, por eso sí puede ver los datos.
-- Lo esperado: salen las 3 mascotas, y en la segunda consulta también
-- el nombre del dueño.

CALL sp_listar_mascotas();
CALL sp_listar_mascotas_con_dueno();


-- 3) PRUEBA DE SEGURIDAD: vet_app NO tiene acceso directo a las tablas
-- Si alguien intenta saltarse los procedimientos y consultar la tabla
-- directamente, MySQL no lo deja.
-- Lo esperado: Error 1142, SELECT command denied to user 'vet_app'.

SELECT * FROM mascota;

-- Lo mismo pasa si intenta borrar algo por su cuenta.
-- Lo esperado: Error 1142, DELETE command denied to user 'vet_app'.

DELETE FROM mascota WHERE codigo = 'M01';


-- 4) Integridad: cliente duplicado (PK)
-- La cédula 101110111 ya es de Ana Mora, así que no se puede repetir.
-- Lo esperado: "Ya existe un cliente con esa cédula."

CALL sp_insertar_cliente('101110111', 'Otra Persona', '80000000');

-- 5) Integridad: mascota con dueño inexistente (FK)
-- No hay ningún cliente con la cédula 999999999, entonces la mascota
-- no se puede registrar porque quedaría sin dueño.
-- Lo esperado: "El cliente dueño no existe."

CALL sp_insertar_mascota('M99', 'Fantasma', 'OTRO', 20, '999999999');

-- 7) Integridad: edad fuera del rango 18-60 (CHECK)
-- La base no acepta edades menores de 18 ni mayores de 60.
-- Lo esperado: Error 3819, Check constraint 'chk_mascota_edad' is violated.

CALL sp_insertar_mascota('M98', 'Chiquito', 'GATO', 5, '101110111');

-- 6) Privilegios efectivos de vet_app
-- Sirve para confirmar qué puede hacer realmente esta cuenta.
-- Lo esperado: solo USAGE y EXECUTE sobre los 7 procedimientos;
-- nada de SELECT, INSERT, UPDATE ni DELETE sobre las tablas.

SHOW GRANTS;
