CREATE TABLE Usuario (
    email   VARCHAR(254)    NOT NULL,
    nombre  VARCHAR(32)   NOT NULL,
    apellido     VARCHAR(32)    NOT NULL,
    cedula  INT   NOT NULL   UNIQUE,
    fecha_nacimiento DATE    NOT NULL,
    contrasenia  VARCHAR(32) NOT NULL,
    PRIMARY KEY (email)
);

CREATE TABLE Profesor (
    email           VARCHAR(254)    NOT NULL,
    cv              VARCHAR(128)    NOT NULL, -- se guarda un enlace al CV Google Drive o un Bucket S3
    fecha_ingreso   DATE            NOT NULL,
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES Usuario(email)    ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE TABLE Titulo (
    email_profesor      VARCHAR(254)    NOT NULL,
    nombre_titulo       VARCHAR(128)    NOT NULL,
    grado_titulo        VARCHAR(128)    NOT NULL,
    universidad_titulo  VARCHAR(128)    NOT NULL,
    PRIMARY KEY (email_profesor, nombre_titulo, grado_titulo, universidad_titulo),
    FOREIGN KEY (email_profesor)
);

CREATE TABLE Cliente (
    email VARCHAR(254) NOT NULL,
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES Usuario(email)    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Estudiante (
    email VARCHAR(254) NOT NULL,
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES Usuario(email)    ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Carrera (
    codigo_carrera  VARCHAR(16)   NOT NULL,
    nombre  VARCHAR(16)   NOT NULL,
    tipo    VARCHAR(16) NOT NULL,
    descripcion  TEXT NOT NULL,
    email_coordinador VARCHAR(254),
    PRIMARY KEY (codigo_carrera),
    FOREIGN KEY (email_coordinador) REFERENCES Profesor(email) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Materia (
    codigo_materia  VARCHAR(16)   NOT NULL,
    codigo_carrera   VARCHAR(16)   NOT NULL,
    nombre  VARCHAR(16)   NOT NULL,
    nivel   VARCHAR(16)    NOT NULL,
    PRIMARY KEY (codigo_materia),
    FOREIGN KEY (codigo_carrera) REFERENCES Carrera(codigo_carrera) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Curso (
    codigo_materia  VARCHAR(16)   NOT NULL,
    seccion INT  NOT NULL CHECK (seccion > 0),
    fecha_inicio    DATE     NOT NULL,
    fecha_fin    DATE   NOT NULL,
    horario VARCHAR(32)  NOT NULL,
    email_profesor VARCHAR(254) NOT NULL,
    PRIMARY KEY (codigo_materia, seccion, fecha_inicio),
    FOREIGN KEY (codigo_materia) REFERENCES Materia(codigo_materia) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (email_profesor) REFERENCES Profesor(email) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Producto (
    id  INT GENERATED ALWAYS AS IDENTITY,
    nombre   VARCHAR(32)  NOT NULL,
    stock    INT   NOT NULL DEFAULT 0 CHECK (stock >= 0),
    precio   DECIMAL(10,2)  NOT NULL CHECK (precio >= 0),
    descripcion TEXT NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE Instrumento (
    id_producto  INT   NOT NULL,
    marca VARCHAR(32)   NOT NULL,
    modelo VARCHAR(32)  NOT NULL,
    PRIMARY KEY (id_producto),
    FOREIGN KEY (id_producto) REFERENCES Producto(id) ON DELETE CASCADE
);

CREATE TABLE CD (
    id_producto  INT   NOT NULL,
    tipo     VARCHAR(8) NOT NULL,
    discografica VARCHAR(32)    NOT NULL,
    PRIMARY KEY (id_producto),
    FOREIGN KEY (id_producto) REFERENCES Producto(id) ON DELETE CASCADE
);

CREATE TABLE Accesorio (
    id_producto  INT   NOT NULL,
    marca        VARCHAR(32) NOT NULL,
    PRIMARY KEY (id_producto),
    FOREIGN KEY (id_producto) REFERENCES Producto(id) ON DELETE CASCADE
);

CREATE TABLE Compatible (
    id_instrumento  INT   NOT NULL,
    id_accesorio    INT NOT NULL,
    PRIMARY KEY (id_instrumento, id_accesorio),
    FOREIGN KEY (id_instrumento) REFERENCES Instrumento(id_producto) ON DELETE CASCADE,
    FOREIGN KEY (id_accesorio) REFERENCES Accesorio(id_producto) ON DELETE CASCADE
);

CREATE TABLE Transaccion (
    id  INT GENERATED ALWAYS AS IDENTITY,
    n_ref    INT   NOT NULL UNIQUE,
    monto_total INT  NOT NULL,
    fecha    DATE   NOT NULL,
    hora     TIME    NOT NULL,
    email_cliente VARCHAR(254)   NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (email_cliente) REFERENCES Cliente(email) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Pertenece (
    id_producto INT  NOT NULL,
    id_transaccion INT  NOT NULL,
    cantidad    INT DEFAULT 1 CHECK (cantidad > 0),
    precio      INT NOT NULL,
    PRIMARY KEY (id_producto, id_transaccion),
    FOREIGN KEY (id_producto) REFERENCES Producto(id) ON DELETE NO ACTION,
    FOREIGN KEY (id_transaccion) REFERENCES Transaccion(id) ON DELETE CASCADE
);

CREATE TABLE Categoria (
    nombre  VARCHAR(32)   NOT NULL,
    PRIMARY KEY (nombre)
);

CREATE TABLE Esta_en (
    id_instrumento  INT   NOT NULL,
    nombre_categoria VARCHAR(32)    NOT NULL,
    PRIMARY KEY (id_instrumento, nombre_categoria),
    FOREIGN KEY (id_instrumento) REFERENCES Instrumento(id_producto) ON DELETE CASCADE,
    FOREIGN KEY (nombre_categoria) REFERENCES Categoria(nombre) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Es (
    nombre_padre    VARCHAR(32) NOT NULL,
    nombre_hijo  VARCHAR(32) NOT NULL,
    PRIMARY KEY (nombre_padre, nombre_hijo),
    FOREIGN KEY (nombre_padre) REFERENCES Categoria(nombre) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nombre_hijo) REFERENCES Categoria(nombre) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE De (
    nombre_categoria VARCHAR(32)    NOT NULL,
    codigo_materia  VARCHAR(16)   NOT NULL,
    PRIMARY KEY (nombre_categoria, codigo_materia),
    FOREIGN KEY (nombre_categoria) REFERENCES Categoria(nombre) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (codigo_materia) REFERENCES Materia(codigo_materia) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Prela (
    codigo_prela    VARCHAR(16) NOT NULL,
    codigo_prelada  VARCHAR(16)   NOT NULL,
    PRIMARY KEY (codigo_prela, codigo_prelada),
    FOREIGN KEY (codigo_prela) REFERENCES Materia(codigo_materia) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (codigo_prelada) REFERENCES Materia(codigo_materia) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Estudia (
    email_estudiante    VARCHAR(254) NOT NULL,
    codigo_carrera  VARCHAR(16)   NOT NULL,
    fecha_inicio    DATE     NOT NULL,
    fecha_fin    DATE,
    PRIMARY KEY (email_estudiante, codigo_carrera),
    FOREIGN KEY (email_estudiante) REFERENCES Estudiante(email) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (codigo_carrera) REFERENCES Carrera(codigo_carrera) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Inscribe (
    email_estudiante VARCHAR(254)    NOT NULL,
    codigo_materia  VARCHAR(16)   NOT NULL,
    seccion INT  NOT NULL  CHECK (seccion > 0),
    fecha_inicio    DATE     NOT NULL,
    calificacion_prof INT CHECK (nota > 0 AND nota < 6),
    calificacion_materia INT CHECK (nota > 0 AND nota < 6),
    nota    INT CHECK (nota > 0 AND nota < 6),
    PRIMARY KEY (email_estudiante, codigo_materia, seccion, fecha_inicio),
    FOREIGN KEY (email_estudiante) REFERENCES Estudiante(email) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (codigo_materia, seccion, fecha_inicio) REFERENCES Curso(codigo_materia, seccion, fecha_inicio) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Genero (
    id_CD   INT    NOT NULL,
    nombre_genero VARCHAR(32)   NOT NULL,
    PRIMARY KEY (id_CD, nombre_genero),
    FOREIGN KEY (id_CD) REFERENCES CD(id) ON DELETE CASCADE
);

CREATE TABLE Artista (
    id_CD    INT   NOT NULL,
    nombre_artista VARCHAR(32)  NOT NULL,
    PRIMARY KEY (id_CD, nombre_artista),
    FOREIGN KEY (id_CD) REFERENCES CD(id) ON DELETE CASCADE
);