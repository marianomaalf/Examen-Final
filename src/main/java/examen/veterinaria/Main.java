package examen.veterinaria;
import examen.veterinaria.controller.VeterinariaController;
import examen.veterinaria.repository.*;
import examen.veterinaria.service.VeterinariaService;
import examen.veterinaria.view.VentanaVeterinaria;
import javax.swing.JOptionPane;
import javax.swing.SwingUtilities;

public class Main {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            ConexionMySQL conexion;
            try {
                conexion = ConexionMySQL.desdeVariablesDeEntorno();
            } catch (PersistenciaException e) {
                JOptionPane.showMessageDialog(null, e.getMessage(), "Configuración incompleta", JOptionPane.ERROR_MESSAGE);
                return;
            }
            RepositorioCliente clientes = new RepositorioClienteMySQL(conexion);
            RepositorioMascota mascotas = new RepositorioMascotaMySQL(conexion);
            VeterinariaService service = new VeterinariaService(clientes,mascotas);
            new VentanaVeterinaria(new VeterinariaController(service)).setVisible(true);
        });
    }
}
