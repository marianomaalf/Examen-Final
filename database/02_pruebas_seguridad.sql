
USE veterinaria;


CALL sp_insertar_cliente('101110111', 'Ana Mora', '88881111');
CALL sp_insertar_cliente('202220222', 'Luis Solis', '87772222');
CALL sp_insertar_mascota('M01', 'Luna', 'GATO', 3, '101110111');
CALL sp_insertar_mascota('M02', 'Rocky', 'PERRO', 5, '202220222');
CALL sp_insertar_mascota('M03', 'Nina', 'PERRO', 1, '101110111');

CALL sp_listar_mascotas();

SELECT * FROM mascota;

DELETE FROM mascota WHERE codigo = 'M01';

CALL sp_insertar_cliente('101110111', 'Otra Persona', '80000000');

CALL sp_insertar_mascota('M99', 'Fantasma', 'OTRO', 2, '999999999');

SHOW GRANTS;
