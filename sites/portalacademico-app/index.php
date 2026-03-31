<?php
error_reporting(E_ALL ^ E_NOTICE);

$dbHost = getenv('DB_HOST') ?: 'db';
$dbName = getenv('DB_NAME') ?: 'portal_academico';
$dbUser = getenv('DB_USER') ?: 'portal_app';
$dbPass = getenv('DB_PASSWORD') ?: 'P0rtal_2026!Sql#Lab';

if (isset($_POST["enviar"])) {
    $usuario = $_POST["usuario"];
    $clave = $_POST["clave"];

    try {
        $con = new PDO("mysql:host=$dbHost;dbname=$dbName", $dbUser, $dbPass);
        $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        // Mantener vulnerable a proposito para el laboratorio
        $query = "SELECT * FROM clientes WHERE user= '$usuario' AND password = '$clave'";
        $autent = $con->query($query);

        foreach ($autent as $columna) {
            header("Location: sqli.php?id=" . $columna[0]);
            exit;
        }

        echo '<script>alert("Usuario o contraseña incorrecta")</script>';
    } catch (PDOException $error) {
        echo "<div style=\"color:white;padding:20px\">Error de conexión: " . htmlspecialchars($error->getMessage()) . "</div>";
        exit();
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Portal Académico - Acceso</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <main class="page">
    <section class="card">
      <span class="badge">Laboratorio web</span>
      <h1>Portal Académico</h1>
      <p class="lead">Servicio de consulta para estudiantes y administrativos. Esta aplicación conserva debilidades intencionales para fines pedagógicos en un entorno controlado.</p>

      <form method="POST">
        <label for="usuario">Usuario</label>
        <input id="usuario" name="usuario" type="text" placeholder="Ej. estudiante01" required>

        <label for="clave">Contraseña</label>
        <input id="clave" name="clave" type="password" placeholder="Ingrese su contraseña" required>

        <div class="actions">
          <button class="btn btn-primary" type="submit" name="enviar">Ingresar al portal</button>
          <a class="btn btn-secondary" href="registro.php">Crear cuenta de prueba</a>
        </div>
      </form>

      <div class="note">
        Sitio de laboratorio para reconocimiento y evaluación de debilidades web. No usar fuera del entorno aislado de clase.
      </div>
    </section>
  </main>
</body>
</html>
