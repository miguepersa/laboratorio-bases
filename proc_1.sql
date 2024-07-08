CREATE PROCEDURE Crear_Usuario(
    email   VARCHAR(254),
    nombre  VARCHAR(32),
    apellido     VARCHAR(32)
    cedula  INT,
    fecha_nacimiento DATE,
    contrasenia  VARCHAR(32)
)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO Usuario VALUES (
       email, nombre, apellido, cedula, fecha_nacimiento, contrasenia
    )

END
$$;

CREATE PROCEDURE Crear_Producto(
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
        DEFAULT, nombre, stock. precio, descripcion
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
    id_producto INT
BEGIN
    CALL Crear_Producto(nombre, stock, precio, descripcion, id_producto)
    INSERT INTO Instrumento VALUES (
        id_producto, marca, modelo
    )
    --IF (SELECT * FROM Categoria WHERE nombre = categoria) IS NULL THEN
        --CALL Crear_Categoria(categoria)
    --END IF
    --CALL Categoria_Instrumento(id_producto, categoria)
END
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
    id_producto INT
BEGIN
    CALL Crear_Producto(nombre, stock, precio, descripcion, id_producto)
    INSERT INTO CD VALUES (
        id_producto, tipo, discografica
    )
    --CALL Crear_Genero(id_producto, nombre_genero)
    --CALL Crear_Artista(id_producto, nombre_artista)
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
    id_producto INT
BEGIN
    CALL Crear_Producto(nombre, stock, precio, descripcion, id_producto)
    INSERT INTO Accesorio VALUES (
        id_producto, marca
    )

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
    )
END
$$;

CREATE PROCEDURE Actualizar_Stock(
    id_producto,
    valor INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Producto
    SET stock = valor
    WHER id = id_producto
END
$$;

--monto total se calcula mediante el procedimiento Agregar_Producto_a_Transaccion
CREATE PROCEDURE Crear_Transaccion(
    n_ref    INT,
    fecha    DATE,
    hora     TIME,
    email_cliente VARCHAR(254)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF (SELECT * FROM Cliente WHERE email = email_cliente) IS NULL THEN
    INSERT INTO ClientE VALUES (
        email_cliente
    )
    END IF
    INSERT INTO Transaccion VALUES (
        DEFAULT, n_ref, 0, fecha, hora, email_cliente
    )
END
$$;


CREATE PROCEDURE Agregar_Producto_a_Transaccion(
    id_producto INT,
    id_transaccion INT,
    cantidad INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    stock INT
    precio INT
BEGIN
    SELECT Producto.stock INTO stock FROM Producto WHERE id = id_producto
    CALL Actualizar_Stock(id_producto, stock - cantidad)

    SELECT Producto.precio INTO precio FROM Producto WHERE id = id_producto
    INSERT INTO Pertenece VALUES (
        id_producto, id_transaccion, candidad, precio
    )

    UPDATE Transaccion 
    SET monto_total = monto_total + precio*cantidad
    WHERE id = id_transaccion 
END
$$;


CREATE PROCEDURE Crear_Profesor(
    email           VARCHAR(254),
    cv              VARCHAR(128), 
    fecha_ingreso   DATE,
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Profesor VALUES (
        email, cv, fecha_ingreso
    )
END
$$;


CREATE PROCEDURE Crear_Carrera(
    codigo_carrera  VARCHAR(16),
    nombre  VARCHAR(16),
    tipo    VARCHAR(16),
    descripcion  TEXT,
    email_coordinador VARCHAR(254),
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Profesor VALUES (
        codigo_carrera, nombre, tipo, descripcion, email_coordinador
    )
END
$$;

--check?!?!?!
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
    INSERT INTO Profesor VALUES (
        codigo_materia, codigo_carrera, nombre, nivel
    )
    --IF (SELECT * FROM Categoria WHERE nombre = categoria) IS NULL THEN
        --CALL Crear_Categoria(categoria)
    --END IF
    --CALL Categoria_Materia(id_producto, categoria)
END
$$;


CREATE PROCEDURE Prela(
    codigo_prela    VARCHAR(16) NOT NULL,
    codigo_prelada  VARCHAR(16)   NOT NULL,     
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Prela VALUES (
        codigo_prela, codigo_prelada
    )
END
$$;

