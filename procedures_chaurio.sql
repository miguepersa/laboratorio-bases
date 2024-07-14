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

-- Registro de Clientes
CREATE OR REPLACE FUNCTION registrar_cliente(email_cliente TEXT) RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Usuario WHERE email = email_cliente) THEN
        INSERT INTO Cliente (email) VALUES (email_cliente);
    ELSE
        RAISE EXCEPTION 'El email proporcionado no corresponde a un usuario existente';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Registro de Estudiantes
CREATE OR REPLACE FUNCTION registrar_estudiante(email_estudiante TEXT) RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Usuario WHERE email = email_estudiante) THEN
        INSERT INTO Estudiante (email) VALUES (email_estudiante);
    ELSE
        RAISE EXCEPTION 'El email proporcionado no corresponde a un usuario existente';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Inscribir Estudiante a una Carrera
CREATE OR REPLACE FUNCTION inscribir_estudiante_carrera(email_estudiante TEXT, codigo_carrera TEXT, fecha_inicio DATE) RETURNS VOID AS $$
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
CREATE OR REPLACE FUNCTION inscribir_estudiante_curso(email_estudiante TEXT, codigo_materia TEXT, seccion INT, fecha_inicio DATE) RETURNS VOID AS $$
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
CREATE OR REPLACE FUNCTION calificar_estudiante(email_estudiante TEXT, codigo_materia TEXT, seccion INT, nota INT) RETURNS VOID AS $$
BEGIN
    IF nota < 1 OR nota > 5 THEN
        RAISE EXCEPTION 'La nota debe ser un valor entre 1 y 5';
    END IF;

    UPDATE Inscribe SET nota = nota WHERE email_estudiante = email_estudiante AND codigo_materia = codigo_materia AND seccion = seccion;
END;
$$ LANGUAGE plpgsql;

-- Calificar Profesor
CREATE OR REPLACE FUNCTION calificar_profesor(email_estudiante TEXT, codigo_materia TEXT, seccion INT, calificacion_prof INT) RETURNS VOID AS $$
BEGIN
    IF calificacion_prof < 1 OR calificacion_prof > 5 THEN
        RAISE EXCEPTION 'La calificación debe ser un valor entre 1 y 5';
    END IF;

    UPDATE Inscribe SET calificacion_prof = calificacion_prof WHERE email_estudiante = email_estudiante AND codigo_materia = codigo_materia AND seccion = seccion;
END;
$$ LANGUAGE plpgsql;