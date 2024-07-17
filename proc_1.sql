-- Crear un nuevo usuario
    -- email   (VARCHAR(254)) - email del usuario
    -- nombre  (VARCHAR(32)) - nombre del usuario
    -- apellido     (VARCHAR(32)) - apellido del usuario
    -- cedula  (INT) - cedula de identidad del usuario
    -- fecha_nacimiento (DATE) - fecha de nacimiento del usuario
    -- contrasenia  (VARCHAR(32)) - contrasenia del usuario
CREATE OR REPLACE PROCEDURE Crear_Usuario(
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


-- Crear un nuevo producto
    -- nombre   (VARCHAR(32)) - nombre del producto
    -- stock    (INT) - stock inicial del producto
    -- precio   (DECIMAL(10,2)) - precio inicial del producto
    -- descripcion (TEXT) - descripcion del producto
    -- INOUT id_producto (INT) - id del producto creado
CREATE OR REPLACE PROCEDURE Crear_Producto (
    nombre   VARCHAR(32),
    stock    INT,
    precio   DECIMAL(10,2),
    descripcion TEXT,
    INOUT id_producto INT
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

--Crear nuevo producto de tipo instrumento y categoria asociada
        -- nombre   (VARCHAR(32)) - nombre del instrumento
        -- stock    (INT) - stock inicial del instrumento
        -- precio   (DECIMAL(10,2)) - precio del instrumento
        -- descripcion (TEXT) - descripcion del instrumento
        -- marca (VARCHAR(32)) - marca del instrumento
        -- modelo (VARCHAR(32)) - modelo del instrumento
        -- categoria (VARCHAR(32)) - categoria del instrumento
CREATE OR REPLACE PROCEDURE Crear_Instrumento(
    nombre   VARCHAR(32),
    stock    INT,
    precio   DECIMAL(10,2),
    descripcion TEXT,
    marca VARCHAR(32),
    modelo VARCHAR(32),
    categorias VARCHAR(32)[]
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

    FOR i IN 1..array_length(categorias) LOOP
        IF NOT EXISTS (SELECT * FROM Categoria WHERE nombre = categorias[i]) THEN
            CALL Crear_Categoria(categorias[i]);
        END IF;
        CALL Asignar_Categoria_a_Instrumento(id_producto, categorias[i]);
    END LOOP;
END;
$$;

--asociar una categoria a un instrumento
    -- id_instrumento    INT - id del instrumento
    -- nombre_categoria VARCHAR(32) - categoria a asociar
CREATE OR REPLACE PROCEDURE Asignar_Categoria_a_Instrumento(
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


--Crear nuevo producto de tipo CD con genero y artista asociados
        -- nombre   (VARCHAR(32)) - nombre del CD
        -- stock    (INT) - stock inicial del CD
        -- precio   (DECIMAL(10,2)) - precio del CD
        -- descripcion (TEXT) - descripcion del CD
        -- tipo (VARCHAR(8)) - tipo del CD
        -- discografica (VARCHAR(32)) - discografica del CD
        -- nombre_genero (VARCHAR(32)) - genero del CD
        -- nombre_artista (VARCHAR(32)) - artista del CD
CREATE OR REPLACE PROCEDURE Crear_CD(
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
    CALL Crear_Genero(id_producto, nombre_genero);
    CALL Crear_Artista(id_producto, nombre_artista);
END
$$;

-- guardar un genero para un CD
    -- id_CD   INT, - id del CD
    -- nombre_genero VARCHAR(32) - nombre del genero del CD
CREATE OR REPLACE PROCEDURE Crear_Genero(
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

-- guardar un artista para un CD
    -- id_CD   INT, - id del CD
    -- nombre_artista VARCHAR(32) - nombre del artista del CD
CREATE OR REPLACE PROCEDURE Crear_Artista(
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

--Crear nuevo producto de tipo accesorio con instrumento asociado
        -- nombre   (VARCHAR(32)) - nombre del accesorio
        -- stock    (INT) - stock inicial del accesorio
        -- precio   (DECIMAL(10,2)) - precio del accesorio
        -- descripcion (TEXT) - descripcion del accesorio
        -- marca (VARCHAR(8)) - marca del accesorio
        -- id_instrumento (VARCHAR(32)) - id del instrumento asociado al accesorio
CREATE OR REPLACE PROCEDURE Crear_Accesorio(
    nombre   VARCHAR(32),
    stock    INT,
    precio   DECIMAL(10,2),
    descripcion TEXT,
    marca VARCHAR(32),
    id_instrumento INT
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
    INSERT INTO Compatible VALUES (
        id_instrumento, id_producto
    );

END
$$;

--actualizar el stock de un producto
    -- id_producto INT - producto a alterar
    -- valor INT - nuevo stock del producto
CREATE OR REPLACE PROCEDURE Actualizar_Stock(
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

--actualizar el precio de un producto
    -- id_producto INT - producto a alterar
    -- precio INT - nuevo precio del producto
CREATE OR REPLACE PROCEDURE Actualizar_precio (
    id_producto  INT,
    precio   DECIMAL(10,2)

)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Producto
    SET Producto.precio = precio
    WHERE id = id_producto;
END
$$;

--crear una nueva transaccion
    -- n_ref    INT-  numero de referencia de la transaccion
    -- email_cliente VARCHAR(254) - email del cliente que realiza la transaccion
    -- id_productos INT[] - arreglo de los ids de los productos de la transaccion
    -- cantidades INT[] - arrelgo de las cantidades de los productos de la transaccion
CREATE OR REPLACE PROCEDURE Crear_Transaccion(
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

--crear un nuevo profesor
    -- email           VARCHAR(254) - email del profesor
    -- cv              VARCHAR(128) - cv del profesor
    -- fecha_ingreso   DATE -
CREATE OR REPLACE PROCEDURE Crear_Profesor(
    email           VARCHAR(254),
    cv              VARCHAR(128)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Profesor VALUES (
        email, cv, CURRENT_DATE
    );
END
$$;

--crear una nueva carrera
    -- codigo_carrera  VARCHAR(16) - codigo identificador de la carrera
    -- nombre  VARCHAR(16) - nombre de la carrera
    -- tipo    VARCHAR(16) - tipo de la carrera
    -- descripcion  TEXT - descripcion de la carrera
    -- email_coordinador VARCHAR(254) - email del profesor coordinador de la carrera
CREATE OR REPLACE PROCEDURE Crear_Carrera(
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

--crear una nueva materia y su categoria asociada
    -- codigo_materia  VARCHAR(16) - codigo identificador de la materia
    -- codigo_carrera   VARCHAR(16) - codigo de la carrera a la que pertenece la materia
    -- nombre  VARCHAR(16) - nombre de la materia
    -- nivel   VARCHAR(16) - nivel de la materia
    -- categoria VARCHAR(32) -categoria asociada a la materia
CREATE OR REPLACE PROCEDURE Crear_Materia(
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
        CALL Crear_Categoria(categoria);
    END IF;
    CALL Asignar_Categoria_a_Materia(codigo_materia, categoria);
END
$$;

--asignar una categoria a una materia
    -- codigo_materia  VARCHAR(16) - codigo de la materia
    -- nombre_categoria VARCHAR(32) - categoria a asociar
CREATE OR REPLACE PROCEDURE Asignar_Categoria_a_Materia(
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

--establecer una relacion de prelacion entre dos materias
    -- codigo_prela    VARCHAR(16) - codigo de la materia requisito
    -- codigo_prelada  VARCHAR(16)  - codigo de la materia prelada 
CREATE OR REPLACE PROCEDURE Prelar (
    codigo_prela    VARCHAR(16),
    codigo_prelada  VARCHAR(16)   
)
LANGUAGE plpgsql
AS $$
BEGIN

    if (SELECT COUNT(DISTINCT codigo_carrera) FROM Materia WHERE codigo_materia IN (codigo_prelada, codigo_prela)) > 1 THEN
        RAISE EXCEPTION 'Las materias deben pertenecer a la misma carrera';
    END IF;

    INSERT INTO Prela VALUES (
        codigo_prela, codigo_prelada
    );
END
$$;

CREATE OR REPLACE PROCEDURE Cambiar_Coordinador(
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

CREATE OR REPLACE PROCEDURE Graduarse(
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

CREATE OR REPLACE PROCEDURE Crear_Categoria(
    nombre  VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Categoria VALUES (
        nombre
    );
END
$$;


CREATE OR REPLACE PROCEDURE Crear_Subcategoria(
    categoria_padre  VARCHAR(32),
    categoria_hijo  VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Es VALUES (
        categoria_padre, categoria_hijo
    );
END
$$;

CREATE OR REPLACE PROCEDURE Calificar_Materia(
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
    AND Inscribe.fecha_inicio = fecha_inicio;
END
$$;


-- Crear un nuevo curso
--      p_codigo_materia (VARCHAR(16)) - Código de la materia
--      p_seccion (INT) - Sección del curso
--      p_fecha_inicio (DATE) - Fecha de inicio del curso
--      p_fecha_fin (DATE) - Fecha de fin del curso
--      p_horario (VARCHAR(32)) - Horario del curso
--      p_email_profesor (VARCHAR(254)) - Email del profesor
CREATE OR REPLACE PROCEDURE CrearCurso (
    p_codigo_materia VARCHAR(16),
    p_seccion INT,
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_horario VARCHAR(32),
    p_email_profesor VARCHAR(254)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Curso (codigo_materia, seccion, fecha_inicio, fecha_fin, horario, email_profesor)
    VALUES (p_codigo_materia, p_seccion, p_fecha_inicio, p_fecha_fin, p_horario, p_email_profesor);
END;
$$;


-- Cambiar profesor
--      p_codigo_materia (VARCHAR(16)) - Codigo de la materia
--      p_seccion (INT) - Seccion del curso
--      p_fecha_inicio (DATE) - Fecha de inicio del curso
--      p_nuevo_email_profesor (VARCHAR(254)) - Nuevo email del profesor
CREATE OR REPLACE PROCEDURE CambiarProfesor (
    p_codigo_materia VARCHAR(16),
    p_seccion INT,
    p_fecha_inicio DATE,
    p_nuevo_email_profesor VARCHAR(254)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Curso
    SET email_profesor = p_nuevo_email_profesor
    WHERE codigo_materia = p_codigo_materia AND seccion = p_seccion AND fecha_inicio = p_fecha_inicio;
END;
$$;


-- Inscribir Estudiante a una Carrera
CREATE OR REPLACE PROCEDURE inscribir_estudiante_carrera(email_estudiante TEXT, codigo_carrera TEXT, fecha_inicio DATE) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Carrera WHERE codigo = codigo_carrera AND EXISTS (SELECT 1 FROM Materia WHERE codigo_carrera = codigo_carrera)) THEN
        RAISE EXCEPTION 'La carrera no tiene materias asociadas';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE email = email_estudiante) THEN
        INSERT INTO Estudiante (email) VALUES (email_estudiante);
    END IF;

    INSERT INTO Estudia (email_estudiante, codigo_carrera, fecha_inicio) VALUES (email_estudiante, codigo_carrera, fecha_inicio);
END;
$$ LANGUAGE plpgsql;

-- Inscribir Estudiante a un Curso
CREATE OR REPLACE PROCEDURE inscribir_estudiante_curso(email_estudiante TEXT, codigo_materia TEXT, seccion INT, fecha_inicio DATE) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Estudia WHERE email_estudiante = email_estudiante AND codigo_carrera = (SELECT codigo_carrera FROM Tiene WHERE codigo_materia = codigo_materia)) THEN
        RAISE EXCEPTION 'El estudiante no está inscrito en la carrera asociada a la materia';
    END IF;

    IF EXISTS (SELECT 1 FROM Requisito WHERE codigo_materia = codigo_materia AND NOT EXISTS (SELECT 1 FROM Inscribe WHERE email_estudiante = email_estudiante AND codigo_materia = Requisito.codigo_requisito AND nota > 2)) THEN
        RAISE EXCEPTION 'El estudiante no ha aprobado las materias requisito';
    END IF;

    INSERT INTO Inscribe (email_estudiante, codigo_materia, seccion, fecha_inicio) VALUES (email_estudiante, codigo_materia, seccion, fecha_inicio);
END;
$$ LANGUAGE plpgsql;

-- Calificar Estudiante
CREATE OR REPLACE PROCEDURE calificar_estudiante(email_estudiante TEXT, codigo_materia TEXT, seccion INT, nota INT) AS $$
BEGIN
    IF nota < 1 OR nota > 5 THEN
        RAISE EXCEPTION 'La nota debe ser un valor entre 1 y 5';
    END IF;

    UPDATE Inscribe SET nota = nota WHERE email_estudiante = email_estudiante AND codigo_materia = codigo_materia AND seccion = seccion;
END;
$$ LANGUAGE plpgsql;

-- Calificar Profesor
CREATE OR REPLACE PROCEDURE calificar_profesor(email_estudiante TEXT, codigo_materia TEXT, seccion INT, calificacion_prof INT, fecha_inicio DATE) AS $$
BEGIN
    IF calificacion_prof < 1 OR calificacion_prof > 5 THEN
        RAISE EXCEPTION 'La calificación debe ser un valor entre 1 y 5';
    END IF;

    UPDATE Inscribe SET calificacion_prof = calificacion_prof WHERE email_estudiante = email_estudiante AND codigo_materia = codigo_materia AND seccion = seccion AND fecha_inicio = fecha_inicio;
END;
$$ LANGUAGE plpgsql;

-- Calificar Materia
CREATE OR REPLACE PROCEDURE calificar_materia(email_estudiante TEXT, codigo_materia TEXT, seccion INT, calificacion_materia INT, fecha_inicio DATE) AS $$
BEGIN
    IF calificacion_materia < 1 OR calificacion_materia > 5 THEN
        RAISE EXCEPTION 'La calificación debe ser un valor entre 1 y 5';
    END IF;

    UPDATE Inscribe SET calificacion_materia = calificacion_materia WHERE email_estudiante = email_estudiante AND codigo_materia = codigo_materia AND seccion = seccion AND fecha_inicio = fecha_inicio;
END;
$$ LANGUAGE plpgsql;



--------GET---------

CREATE OR REPLACE FUNCTION Obtener_Pensum(
    codigo_carrera_entrada    VARCHAR(16)
)
RETURNS TABLE(
    codigo_materia  VARCHAR(16),
    codigo_carrera   VARCHAR(16),
    nombre  VARCHAR(16),
    nivel   VARCHAR(16)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT * FROM Materia WHERE Materia.codigo_carrera = codigo_carrera_entrada;
END
$$;

CREATE OR REPLACE FUNCTION Obtener_Registro_Transacciones(
    emaill_cliente_entrada    VARCHAR(16)
)
RETURNS TABLE(
    n_ref    INT,
    monto_total INT,
    fecha    DATE,
    hora     TIME,
    email_cliente VARCHAR(254)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT * FROM Transaccion WHERE Transaccion.emaill_cliente = emaill_cliente_entrada ORDER BY fecha, hora;
END
$$;

CREATE OR REPLACE FUNCTION Obtener_Productos_Transaccion(
    id_transaccion_entrada    VARCHAR(16)
)
RETURNS TABLE(
    nombre   VARCHAR(32),
    descripcion TEXT,
	cantidad    INT,
    precio      INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT Producto.nombre, Producto.descripcion, Pertenece.cantidad, Pertenece.precio FROM Pertenece
	INNER JOIN Transaccion ON Transaccion.id = Pertenece.id_transaccion
	INNER JOIN Producto ON Producto.id = Pertenece.id_producto
	WHERE Pertenece.id_transaccion = id_transaccion_entrada;
	
END
$$;


CREATE OR REPLACE FUNCTION Obtener_Cursos_Activos(
)
RETURNS TABLE(
    nombre   VARCHAR(32),
    descripcion TEXT,
	cantidad    INT,
    precio      INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT * FROM Curso
    WHERE fecha_inicio < CURRENT_DATE AND fecha_fin > CURRENT_DATE;
	
END
$$;