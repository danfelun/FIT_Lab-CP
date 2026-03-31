<?php
$dbHost = getenv('DB_HOST') ?: 'db';
$dbName = getenv('DB_NAME') ?: 'portal_academico';
$dbUser = getenv('DB_USER') ?: 'portal_app';
$dbPass = getenv('DB_PASSWORD') ?: 'P0rtal_2026!Sql#Lab';

$resultados = [];
$id = null;

if (isset($_GET["id"])) {
    $id = $_GET["id"];
    $con = new MySQLi($dbHost, $dbUser, $dbPass, $dbName);

    // Mantener vulnerable a proposito para el laboratorio
    $select = "SELECT * FROM clientes WHERE id=" . $id;
    $registros = mysqli_query($con, $select);

    if ($registros) {
        while ($consulta = mysqli_fetch_array($registros)) {
            $resultados[] = $consulta;
        }
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Portal Académico - Consulta</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <main class="page">
    <section class="card wide">
      <span class="badge">Consulta de cliente</span>
      <h1>Ficha de información</h1>
      <p class="lead">Vista interna de información de usuarios para prácticas de reconocimiento y análisis en ambiente controlado.</p>

      <?php if ($id !== null): ?>
        <div class="note"><strong>Consulta solicitada:</strong> id=<?php echo htmlspecialchars($id); ?></div>
      <?php endif; ?>

      <div class="table-wrap" style="margin-top:18px;">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Usuario</th>
              <th>Contraseña</th>
              <th>Correo</th>
              <th>Saldo</th>
            </tr>
          </thead>
          <tbody>
            <?php if (count($resultados) > 0): ?>
              <?php foreach ($resultados as $fila): ?>
                <tr>
                  <td><?php echo htmlspecialchars($fila[0]); ?></td>
                  <td><?php echo htmlspecialchars($fila[1]); ?></td>
                  <td><?php echo htmlspecialchars($fila[2]); ?></td>
                  <td><?php echo htmlspecialchars($fila[3]); ?></td>
                  <td><?php echo htmlspecialchars($fila[4]); ?></td>
                </tr>
              <?php endforeach; ?>
            <?php else: ?>
                <tr><td colspan="5">No se encontraron resultados para la consulta actual.</td></tr>
            <?php endif; ?>
          </tbody>
        </table>
      </div>

      <div class="actions" style="margin-top:18px;">
        <a class="btn btn-secondary" href="index.php">Cerrar sesión</a>
      </div>
    </section>
  </main>
</body>
</html>
