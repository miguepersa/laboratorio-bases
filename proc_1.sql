CREATE PROCEDURE Crear_Usuario(
    email   VARCHAR(254),
    nombre  VARCHAR(32),
    apellido     VARCHAR(32),
    cedula  INT,
    fecha_nacimiento DATE,
    contrasenia  VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Usuario VALUES (
       email, nombre, apellido, cedula, fecha_nacimiento, contrasenia
    );
END
$$;

CREATE PROCEDURE Crear_Producto (
    nombre   VARCHAR(32),
    stock    INT,
    precio   DECIMAL(10,2),
    descripcion TEXT,
    OUT id_producto INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Producto VALUES (
        DEFAULT, nombre, stock, precio, descripcion
    )
    RETURNING id INTO id_producto;
END
$$;

CREATE PROCEDURE Crear_Instrumento(
    nombre   VARCHAR(32),
    stock    INT,
    precio   DECIMAL(10,2),
    descripcion TEXT,
    marca VARCHAR(32),
    modelo VARCHAR(32),
    categoria VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
DECLARE 
    id_producto INT;
BEGIN
    CALL Crear_Producto(nombre, stock, precio, descripcion, id_producto);
    INSERT INTO Instrumento VALUES (
        id_producto, marca, modelo
    );
    IF NOT EXISTS (SELECT * FROM Categoria WHERE nombre = categoria) THEN
        CALL Crear_Categoria(categoria)
    END IF;
    CALL Asignar_Categoria_a_Instrumento(id_producto, categoria);
END;
$$;

CREATE PROCEDURE Asignar_Categoria_a_Instrumento(
    id_instrumento    INT,
    nombre_categoria VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Esta_en VALUES (
        id_instrumento, nombre_categoria
    );
END;
$$;

CREATE PROCEDURE Crear_CD(
    nombre   VARCHAR(32),
    stock    INT,
    precio   DECIMAL(10,2),
    descripcion TEXT,
    tipo     VARCHAR(8),
    discografica VARCHAR(32),
    nombre_genero VARCHAR(32),
    nombre_artista VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
DECLARE 
    id_producto INT;
BEGIN
    CALL Crear_Producto(nombre, stock, precio, descripcion, id_producto);
    INSERT INTO CD VALUES (
        id_producto, tipo, discografica
    );
    CALL Crear_Genero(id_producto, nombre_genero)
    CALL Crear_Artista(id_producto, nombre_artista)
END
$$;

CREATE PROCEDURE Crear_Genero(
    id_CD   INT,
    nombre_genero VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Genero VALUES (
        id_CD, nombre_genero
    );
END
$$;

CREATE PROCEDURE Crear_Artista(
    id_CD   INT,
    nombre_artista VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Artista VALUES (
        id_CD, nombre_artista
    );
END
$$;

CREATE PROCEDURE Crear_Accesorio(
    nombre   VARCHAR(32),
    stock    INT,
    precio   DECIMAL(10,2),
    descripcion TEXT,
    marca VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
DECLARE 
    id_producto INT;
BEGIN
    CALL Crear_Producto(nombre, stock, precio, descripcion, id_producto);
    INSERT INTO Accesorio VALUES (
        id_producto, marca
    );

END
$$;

CREATE PROCEDURE Asociar_Accesorio_a_Instrumento(
    id_instrumento INT,
    id_accesorio INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Compatible VALUES (
        id_instrumento, id_accesorio
    );
END
$$;

CREATE PROCEDURE Actualizar_Stock(
    id_producto INT,
    valor INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Producto
    SET stock = valor
    WHERE id = id_producto;
END
$$;

CREATE PROCEDURE Crear_Transaccion(
    n_ref    INT,
    email_cliente VARCHAR(254),
    id_productos INT[],
    cantidades INT[]
)
LANGUAGE plpgsql
AS $$
DECLARE 
    id_transaccion INT;
    i INT;
    stock INT;
    precio INT;
BEGIN
    IF NOT EXISTS (SELECT * FROM Cliente WHERE email = email_cliente) THEN
        INSERT INTO Cliente VALUES (
            email_cliente
        );
    END IF;
    INSERT INTO Transaccion VALUES (
        DEFAULT, n_ref, 0, CURRENT_DATE, CURRENT_TIME, email_cliente
    ) RETURNING id INTO id_transaccion;

    FOR i IN 1..array_length(id_productos) LOOP
    
        SELECT Producto.stock, Producto.precio INTO stock, precio FROM Producto WHERE id = id_productos[i];
        CALL Actualizar_Stock(id_productos[i], stock - cantidades[i]);
 
        INSERT INTO Pertenece VALUES (
            id_productos[i], id_transaccion, candidades[i], precio
        );

        UPDATE Transaccion 
        SET monto_total = monto_total + precio*cantidades[i]
        WHERE id = id_transaccion;

    END LOOP;
END
$$; 


CREATE PROCEDURE Crear_Profesor(
    email           VARCHAR(254),
    cv              VARCHAR(128), 
    fecha_ingreso   DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Profesor VALUES (
        email, cv, fecha_ingreso
    );
END
$$;


CREATE PROCEDURE Crear_Carrera(
    codigo_carrera  VARCHAR(16),
    nombre  VARCHAR(16),
    tipo    VARCHAR(16),
    descripcion  TEXT,
    email_coordinador VARCHAR(254)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Carrera VALUES (
        codigo_carrera, nombre, tipo, descripcion, email_coordinador
    );
END
$$;


CREATE PROCEDURE Crear_Materia(
    codigo_materia  VARCHAR(16),
    codigo_carrera   VARCHAR(16),
    nombre  VARCHAR(16),
    nivel   VARCHAR(16),
    categoria VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Materia VALUES (
        codigo_materia, codigo_carrera, nombre, nivel
    );
    IF NOT EXISTS (SELECT * FROM Categoria WHERE nombre = categoria) THEN
        CALL Crear_Categoria(categoria)
    END IF
    CALL Asignar_Categoria_a_Materia(codigo_materia, categoria)
END
$$;

CREATE PROCEDURE Asignar_Categoria_a_Materia(
    codigo_materia  VARCHAR(16),
    nombre_categoria VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO De VALUES (
        id_instrumento, nombre_categoria
    );
END;
$$;


CREATE PROCEDURE Prelar (
    codigo_prela    VARCHAR(16),
    codigo_prelada  VARCHAR(16)   
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Prela VALUES (
        codigo_prela, codigo_prelada
    );
END
$$;

CREATE PROCEDURE Cambiar_Coordinador(
    codigo_carrera  VARCHAR(16),   
    email_coordinador    VARCHAR(254)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Carrera
    SET Carrera.email_coordinador = email_coordinador
    WHERE Carrera.codigo_carrera = codigo_carrera;
END
$$;

CREATE PROCEDURE Graduarse(
    email_estudiante  VARCHAR(254),
    codigo_carrera  VARCHAR(16)   
)
LANGUAGE plpgsql
AS $$
DECLARE
    materias INT;
    notas INT;
BEGIN

    SELECT COUNT(*) INTO materias From Materia
    WHERE Materia.codigo_carrera = codigo_carrera;

    SELECT COUNT(DISTINCT Inscribe.codigo_materia) INTO notas FROM Inscribe 
    INNER JOIN Materia ON Materia.codigo_materia = Inscribe.codigo_materia
    WHERE Inscribe.email_estudiante = email_estudiante
    AND Materia.codigo_carrera = codigo_carrera
    AND Inscribe.nota > 2;
    
    IF materias != notas THEN
        RAISE EXCEPTION 'estudiante no ha aprobado todas las materias de la carrera';
    END IF;

    UPDATE Estudia 
    SET fecha_fin = CURRENT_DATE
    WHERE Estudia.email_estudiante = email_estudiante;

END
$$;

CREATE PROCEDURE Crear_Categoria(
    nombre  VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Categoria VALUES (
        nombre_artista
    );
END
$$;

CREATE PROCEDURE Calificar_Materia(
    email_estudiante  VARCHAR(16),   
    codigo_materia    VARCHAR(254),
    seccion INT,
    fecha_inicio    DATE,
    calificacion INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Inscribe
    SET calificacion_materia = calificacion
    WHERE Inscribe.email_estudiante = email_estudiante
    AND Inscribe.codigo_materia = codigo_materia
    AND Inscribe.seccion = seccion
    AND Inscribe.fecha_inicio = fecha_inicio
END
$$;
