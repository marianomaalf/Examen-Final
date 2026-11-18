package examen.veterinaria.repository;
import examen.veterinaria.model.Mascota;
import java.util.List;

//interface que define las operaciones de persistencia de mascotas
public interface RepositorioMascota {
    List<Mascota> cargarTodos();
    void insertar(Mascota mascota);
    void actualizar(Mascota mascota);
    void eliminar(String codigo);
    List<String> listarConDueno();
}
