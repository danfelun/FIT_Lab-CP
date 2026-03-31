<?php
if (isset($_POST["enviar"])) {
    $dbHost = getenv('DB_HOST') ?: 'db';
    $dbName = getenv('DB_NAME') ?: 'portal_academico';
    $dbUser = getenv('DB_USER') ?: 'portal_app';
    $dbPass = getenv('DB_PASSWORD') ?: 'P0rtal_2026!Sql#Lab';

    $usuario = $_POST["usuario"];
    $clave = $_POST["clave"];
    $correo = $_POST["correo"];
    $saldo = $_POST["saldo"];

    try {
        $con = new PDO("mysql:host=$dbHost;dbname=$dbName", $dbUser, $dbPass);
        $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        $stmt = $con->prepare("INSERT INTO clientes (user, password, correo, saldo) VALUES (?, ?, ?, ?)");
        $stmt->execute([$usuario, $clave, $correo, $saldo]);

        echo '<script>alert("Registro completado correctamente"); window.location.href="index.php";</script>';
        exit;
    } catch (PDOException $error) {
        echo "<div style=\"color:white;padding:20px\">Error: " . htmlspecialchars($error->getMessage()) . "</div>";
        exit();
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Portal Académico - Registro</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <main class="page">
    <section class="card">
      <span class="badge">Registro de prueba</span>
      <h1>Crear cuenta temporal</h1>
      <p class="lead">Formulario de registro utilizado para poblar datos de ejemplo en el laboratorio.</p>

      <form method="POST">
        <label for="usuario">Usuario</label>
        <input id="usuario" name="usuario" type="text" placeholder="Nuevo usuario" required>

        <label for="clave">Contraseña</label>
        <input id="clave" name="clave" type="password" placeholder="Contraseña" required>

        <label for="correo">Correo</label>
        <input id="correo" name="correo" type="email" placeholder="correo@ejemplo.edu.co" required>

        <label for="saldo">Saldo</label>
        <input id="saldo" name="saldo" type="text" placeholder="100000" required>

        <div class="actions">
          <button class="btn btn-primary" type="submit" name="enviar">Registrar usuario</button>
          <a class="btn btn-secondary" href="index.php">Volver al inicio</a>
        </div>
      </form>
    </section>
  </main>
</body>
</html>
