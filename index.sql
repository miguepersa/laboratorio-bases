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
CREATE INDEX idx_es_categoria_padre ON Es(nombre_padre);

-- Índices en columnas utilizadas en filtros de búsqueda
CREATE INDEX idx_usuario_nombre ON Usuario(nombre);
CREATE INDEX idx_usuario_apellido ON Usuario(apellido);
CREATE INDEX idx_producto_nombre ON Producto(nombre);

-- Índices en columnas utilizadas en ordenaciones
CREATE INDEX idx_curso_fecha_inicio ON Curso(fecha_inicio);
CREATE INDEX idx_transaccion_fecha ON Transaccion(fecha);

-- Índices compuestos si es necesario (si las consultas suelen filtrar por varias columnas)
CREATE INDEX idx_inscribe_estudiante_materia_seccion ON Inscribe(email_estudiante, codigo_materia, seccion);
