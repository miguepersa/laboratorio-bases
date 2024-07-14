-- Crear un nuevo usuario
    -- email   (VARCHAR(254)) - email del usuario
    -- nombre  (VARCHAR(32)) - nombre del usuario
    -- apellido     (VARCHAR(32)) - apellido del usuario
    -- cedula  (INT) - cedula de identidad del usuario
    -- fecha_nacimiento (DATE) - fecha de nacimiento del usuario
    -- contrasenia  (VARCHAR(32)) - contrasenia del usuario
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


-- Crear un nuevo producto
    -- nombre   (VARCHAR(32)) - nombre del producto
    -- stock    (INT) - stock inicial del producto
    -- precio   (DECIMAL(10,2)) - precio inicial del producto
    -- descripcion (TEXT) - descripcion del producto
    -- INOUT id_producto (INT) - id del producto creado
CREATE PROCEDURE Crear_Producto (
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

--asociar una categoria a un instrumento
    -- id_instrumento    INT - id del instrumento
    -- nombre_categoria VARCHAR(32) - categoria a asociar
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


--Crear nuevo producto de tipo CD con genero y artista asociados
        -- nombre   (VARCHAR(32)) - nombre del CD
        -- stock    (INT) - stock inicial del CD
        -- precio   (DECIMAL(10,2)) - precio del CD
        -- descripcion (TEXT) - descripcion del CD
        -- tipo (VARCHAR(8)) - tipo del CD
        -- discografica (VARCHAR(32)) - discografica del CD
        -- nombre_genero (VARCHAR(32)) - genero del CD
        -- nombre_artista (VARCHAR(32)) - artista del CD
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

-- guardar un genero para un CD
    -- id_CD   INT, - id del CD
    -- nombre_genero VARCHAR(32) - nombre del genero del CD
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

-- guardar un artista para un CD
    -- id_CD   INT, - id del CD
    -- nombre_artista VARCHAR(32) - nombre del artista del CD
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

--Crear nuevo producto de tipo accesorio con instrumento asociado
        -- nombre   (VARCHAR(32)) - nombre del accesorio
        -- stock    (INT) - stock inicial del accesorio
        -- precio   (DECIMAL(10,2)) - precio del accesorio
        -- descripcion (TEXT) - descripcion del accesorio
        -- marca (VARCHAR(8)) - marca del accesorio
        -- id_instrumento (VARCHAR(32)) - id del instrumento asociado al accesorio
CREATE PROCEDURE Crear_Accesorio(
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

--actualizar el precio de un producto
    -- id_producto INT - producto a alterar
    -- precio INT - nuevo precio del producto
CREATE PROCEDURE Actualizar_precio (
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

--crear un nuevo profesor
    -- email           VARCHAR(254) - email del profesor
    -- cv              VARCHAR(128) - cv del profesor
    -- fecha_ingreso   DATE -
CREATE PROCEDURE Crear_Profesor(
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

--crear una nueva materia y su categoria asociada
    -- codigo_materia  VARCHAR(16) - codigo identificador de la materia
    -- codigo_carrera   VARCHAR(16) - codigo de la carrera a la que pertenece la materia
    -- nombre  VARCHAR(16) - nombre de la materia
    -- nivel   VARCHAR(16) - nivel de la materia
    -- categoria VARCHAR(32) -categoria asociada a la materia
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

--asignar una categoria a una materia
    -- codigo_materia  VARCHAR(16) - codigo de la materia
    -- nombre_categoria VARCHAR(32) - categoria a asociar
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

--establecer una relacion de prelacion entre dos materias
    -- codigo_prela    VARCHAR(16) - codigo de la materia requisito
    -- codigo_prelada  VARCHAR(16)  - codigo de la materia prelada 
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

-- Creacion de indices

-- Índices en claves foráneas
CREATE INDEX idx_profesor_email ON Profesor(email);
CREATE INDEX idx_cliente_email ON Cliente(email);
CREATE INDEX idx_estudiante_email ON Estudiante(email);
CREATE INDEX idx_carrera_email_coordinador ON Carrera(email_coordinador);
CREATE INDEX idx_materia_codigo_carrera ON Materia(codigo_carrera);
CREATE INDEX idx_curso_codigo_materia ON Curso(codigo_materia);
CREATE INDEX idx_curso_email_profesor ON Curso(email_profesor);
CREATE INDEX idx_transaccion_email_cliente ON Transaccion(email_cliente);
CREATE INDEX idx_pertenece_id_producto ON Pertenece(id_producto);
CREATE INDEX idx_pertenece_id_transaccion ON Pertenece(id_transaccion);
CREATE INDEX idx_esta_en_id_instrumento ON Esta_en(id_instrumento);
CREATE INDEX idx_esta_en_nombre_categoria ON Esta_en(nombre_categoria);
CREATE INDEX idx_de_nombre_categoria ON De(nombre_categoria);
CREATE INDEX idx_de_codigo_materia ON De(codigo_materia);
CREATE INDEX idx_prela_codigo_prela ON Prela(codigo_prela);
CREATE INDEX idx_prela_codigo_prelada ON Prela(codigo_prelada);
CREATE INDEX idx_estudia_email_estudiante ON Estudia(email_estudiante);
CREATE INDEX idx_estudia_codigo_carrera ON Estudia(codigo_carrera);
CREATE INDEX idx_inscribe_email_estudiante ON Inscribe(email_estudiante);
CREATE INDEX idx_inscribe_codigo_materia ON Inscribe(codigo_materia);
CREATE INDEX idx_inscribe_seccion ON Inscribe(seccion);
CREATE INDEX idx_genero_id_CD ON Genero(id_CD);
CREATE INDEX idx_artista_id_CD ON Artista(id_CD);

-- Índices en columnas utilizadas en filtros de búsqueda
CREATE INDEX idx_usuario_nombre ON Usuario(nombre);
CREATE INDEX idx_usuario_apellido ON Usuario(apellido);
CREATE INDEX idx_producto_nombre ON Producto(nombre);

-- Índices en columnas utilizadas en ordenaciones
CREATE INDEX idx_curso_fecha_inicio ON Curso(fecha_inicio);
CREATE INDEX idx_transaccion_fecha ON Transaccion(fecha);

-- Índices compuestos si es necesario (si las consultas suelen filtrar por varias columnas)
CREATE INDEX idx_inscribe_estudiante_materia_seccion ON Inscribe(email_estudiante, codigo_materia, seccion);
