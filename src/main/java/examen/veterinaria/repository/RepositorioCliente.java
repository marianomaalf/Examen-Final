package examen.veterinaria.repository;
import examen.veterinaria.model.Cliente;
import java.util.List;


//interface que define las operaciones de persistencia de clientes
public interface RepositorioCliente {
    List<Cliente> cargarTodos();
    void insertar(Cliente cliente);
}
