package examen.veterinaria.repository;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class ConexionMySQL {
    private final String url;
    private final String usuario;
    private final String contrasena;

    public ConexionMySQL(String url, String usuario, String contrasena) {
        this.url = url;
        this.usuario = usuario;
        this.contrasena = contrasena;
    }

    public static ConexionMySQL desdeVariablesDeEntorno() {
        return new ConexionMySQL(leer("VET_DB_URL"), leer("VET_DB_USER"), leer("VET_DB_PASSWORD"));
    }

    private static String leer(String nombre) {
        String valor = System.getenv(nombre);
        if (valor == null || valor.isBlank())
            throw new PersistenciaException("Falta configurar la variable de entorno " + nombre + ".", null);
        return valor;
    }

    public Connection abrir() throws SQLException {
        return DriverManager.getConnection(url, usuario, contrasena);
    }

    static PersistenciaException error(String operacion, SQLException e) {
        String detalle;
        if ("45000".equals(e.getSQLState())) {
            detalle = e.getMessage();                       // mensajes SIGNAL de los procedimientos
        } else if (e.getSQLState() != null && e.getSQLState().startsWith("08")) {
            detalle = "No se pudo conectar con la base de datos.";
        } else if (e.getErrorCode() == 1045) {
            detalle = "Usuario o contraseña de la base de datos incorrectos.";
        } else if (e.getErrorCode() == 1370 || e.getErrorCode() == 1142) {
            detalle = "El usuario de la base de datos no tiene permisos para esta operación.";
        } else if (e.getErrorCode() == 3819) {
            detalle = "Los datos no cumplen las restricciones de la base de datos.";
        } else if (e.getErrorCode() == 1265) {
            detalle = "Valor no permitido por la base de datos.";
        } else {
            detalle = e.getMessage();
        }
        return new PersistenciaException(operacion + ": " + detalle, e);
    }
}
