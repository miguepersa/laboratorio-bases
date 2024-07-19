from flask import Flask, render_template, request, redirect, url_for
import psycopg2

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host="18.119.29.79",
        database="academia 4000",
        user="postgres",
        password="ci3391"
    )
    return conn

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/tables')
def tables():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
    tables = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('tables.html', tables=tables)

@app.route('/table/<table_name>')
def view_table(table_name):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(f"SELECT * FROM {table_name}")
    rows = cur.fetchall()
    cur.execute(f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table_name}'")
    columns = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('view_table.html', columns=columns, rows=rows, table_name=table_name)

@app.route('/procedures')
def procedures():
    procedures = [
        'Crear_Usuario',
        'Crear_Producto',
        'Crear_Instrumento',
        'Asignar_Categoria_a_Instrumento',
        'Crear_CD',
        'Crear_Genero',
        'Crear_Artista',
        'Crear_Accesorio',
        'Actualizar_Stock',
        'Actualizar_precio',
        'Crear_Transaccion',
        'Crear_Profesor',
        'Crear_Carrera',
        'Crear_Materia',
        'Asignar_Categoria_a_Materia',
        'Prelar',
        'Cambiar_Coordinador',
        'Graduarse',
        'Crear_Categoria',
        'Crear_Subcategoria',
        'Calificar_Materia',
        'CrearCurso',
        'CambiarProfesor',
        'inscribir_estudiante_carrera',
        'inscribir_estudiante_curso',
        'calificar_estudiante',
        'calificar_profesor',
        'calificar_materia'
    ]
    return render_template('procedures.html', procedures=procedures)

@app.route('/functions')
def functions():
    functions = [
        'Obtener_Pensum',
        'Obtener_Registro_Transacciones',
        'Obtener_Productos_Transaccion',
        'Obtener_Cursos_Activos',
        'Obtener_Instrumento_por_Categoria'
    ]
    return render_template('functions.html', functions=functions)

@app.route('/execute_procedure/<procedure_name>', methods=['GET', 'POST'])
def execute_procedure(procedure_name):
    if request.method == 'POST':
        conn = get_db_connection()
        cur = conn.cursor()
        if procedure_name == 'Crear_Usuario':
            email = request.form['email']
            nombre = request.form['nombre']
            apellido = request.form['apellido']
            cedula = request.form['cedula']
            fecha_nacimiento = request.form['fecha_nacimiento']
            contrasenia = request.form['contrasenia']
            cur.execute("CALL Crear_Usuario(%s, %s, %s, %s, %s, %s)", 
                        (email, nombre, apellido, cedula, fecha_nacimiento, contrasenia))
        
        if procedure_name == 'Crear_Producto':
            nombre = request.form['nombre']
            stock = request.form['stock']
            precio = request.form['precio']
            descripcion = request.form['descripcion']
            id_producto = request.form['id_producto']
            cur.execute("CALL Crear_Producto(%s, %s, %s, %s, %s)", 
                        (nombre, stock, precio, descripcion, id_producto))

        if procedure_name == 'Crear_Instrumento':
            nombre = request.form['nombre']
            stock = request.form['stock']
            precio = request.form['precio']
            descripcion = request.form['descripcion']
            marca = request.form['marca']
            modelo = request.form['modelo']
            categorias = request.form["categorias"].strip().split(" ")
            cur.execute("CALL Crear_Instrumento(%s, %s, %s, %s, %s, %s, %s)", 
                        (nombre, stock, precio, descripcion, marca, modelo, categorias))

        if procedure_name == 'Asignar_Categoria_a_Instrumento':
            id_instrumento = request.form['id_instrumento']
            nombre_categoria = request.form['nombre_categoria']
            cur.execute("CALL Asignar_Categoria_a_Instrumento(%s, %s)", 
                        (id_instrumento, nombre_categoria))
        
        if procedure_name == 'Crear_CD':
            nombre = request.form['nombre']
            stock = request.form['stock']
            precio = request.form['precio']
            descripcion = request.form['descripcion']
            tipo = request.form['tipo']
            discografica = request.form['discografica']
            nombre_genero = request.form['nombre_genero']
            nombre_artista = request.form['nombre_artista']
            cur.execute("CALL Crear_CD(%s, %s, %s, %s, %s, %s, %s, %s)", 
                        (nombre, stock, precio, descripcion, tipo, discografica, nombre_genero, nombre_artista))
        
        if procedure_name == 'Crear_Genero':
            id_CD = request.form['id_CD']
            nombre_genero = request.form['nombre_genero']
            cur.execute("CALL Crear_Genero(%s, %s)", 
                        (id_CD, nombre_genero))
        
        if procedure_name == 'Crear_Artista':
            id_CD = request.form['id_CD']
            nombre_artista = request.form['nombre_artista']
            cur.execute("CALL Crear_Artista(%s, %s)", 
                        (id_CD, nombre_artista))
        
        if procedure_name == 'Crear_Accesorio':
            nombre = request.form['nombre']
            stock = request.form['stock']
            precio = request.form['precio']
            descripcion = request.form['descripcion']
            marca = request.form['marca']
            id_instrumentos = [int(i) for i in request.form["id_instrumentos"].strip().split(" ")]
            cur.execute("CALL Crear_Accesorio(%s, %s, %s, %s, %s, %s)", 
                        (nombre, stock, precio, descripcion, marca, id_instrumentos))
        
        if procedure_name == 'Actualizar_Stock':
            id_producto = request.form['id_producto']
            valor = request.form['valor']
            cur.execute("CALL Actualizar_Stock(%s, %s)", 
                        (id_producto, valor))
        
        if procedure_name == 'Actualizar_precio':
            id_producto = request.form['id_producto']
            precio = request.form['precio']
            cur.execute("CALL Actualizar_precio(%s, %s)", 
                        (id_producto, precio))
        
        if procedure_name == 'Crear_Transaccion':
            n_ref = request.form['n_ref']
            email_cliente = request.form['email_cliente']
            id_productos = [int(i) for i in request.form["id_productos"].strip().split(" ")]
            cantidades = [int(i) for i in request.form["cantidades"].strip().split(" ")]
            cur.execute("CALL Crear_Transaccion(%s, %s, %s, %s)", 
                        (n_ref, email_cliente, id_productos, cantidades))
        
        if procedure_name == 'Crear_Profesor':
            email = request.form['email']
            cv = request.form['cv']
            cur.execute("CALL Crear_Profesor(%s, %s)", 
                        (email, cv))
        
        if procedure_name == 'Crear_Carrera':
            codigo_carrera = request.form['codigo_carrera']
            nombre = request.form['nombre']
            tipo = request.form['tipo']
            descripcion = request.form['descripcion']
            email_coordinador = request.form['email_coordinador']
            cur.execute("CALL Crear_Carrera(%s, %s, %s, %s, %s)", 
                        (codigo_carrera, nombre, tipo, descripcion, email_coordinador))
        
        if procedure_name == 'Crear_Materia':
            codigo_materia = request.form['codigo_materia']
            codigo_carrera = request.form['codigo_carrera']
            nombre = request.form['nombre']
            nivel = request.form['nivel']
            categoria = request.form['categoria']
            cur.execute("CALL Crear_Materia(%s, %s, %s, %s, %s)", 
                        (codigo_materia, codigo_carrera, nombre, nivel, categoria))
        
        if procedure_name == 'Asignar_Categoria_a_Materia':
            codigo_materia = request.form['codigo_materia']
            nombre_categoria = request.form['nombre_categoria']
            cur.execute("CALL Asignar_Categoria_a_Materia(%s, %s)", 
                        (codigo_materia, nombre_categoria))
        
        if procedure_name == 'Prelar':
            codigo_prela = request.form['codigo_prela']
            codigo_prelada = request.form['codigo_prelada']
            cur.execute("CALL Prelar(%s, %s)", 
                        (codigo_prela, codigo_prelada))
        
        if procedure_name == 'Cambiar_Coordinador':
            codigo_carrera = request.form['codigo_carrera']
            email_coordinador = request.form['email_coordinador']
            cur.execute("CALL Cambiar_Coordinador(%s, %s)", 
                        (codigo_carrera, email_coordinador))
        
        if procedure_name == 'Graduarse':
            email_estudiante = request.form['email_estudiante']
            codigo_carrera = request.form['codigo_carrera']
            cur.execute("CALL Graduarse(%s, %s)", 
                        (email_estudiante, codigo_carrera))
        
        if procedure_name == 'Crear_Categoria':
            nombre = request.form['nombre']
            cur.execute("CALL Crear_Categoria(%s)", 
                        (nombre,))
        
        if procedure_name == 'Crear_Subcategoria':
            categoria_padre = request.form['categoria_padre']
            categoria_hijo = request.form['categoria_hijo']
            cur.execute("CALL Crear_Subcategoria(%s, %s)", 
                        (categoria_padre, categoria_hijo))
        
        if procedure_name == 'Calificar_Materia':
            email_estudiante = request.form['email_estudiante']
            codigo_materia = request.form['codigo_materia']
            seccion = request.form['seccion']
            fecha_inicio = request.form['fecha_inicio']
            calificacion = request.form['calificacion']
            cur.execute("CALL Calificar_Materia(%s, %s, %s, %s, %s)", 
                        (email_estudiante, codigo_materia, seccion, fecha_inicio, calificacion))
        
        if procedure_name == 'CrearCurso':
            p_codigo_materia = request.form['p_codigo_materia']
            p_seccion = request.form['p_seccion']
            p_fecha_inicio = request.form['p_fecha_inicio']
            p_fecha_fin = request.form['p_fecha_fin']
            p_horario = request.form['p_horario']
            p_email_profesor = request.form['p_email_profesor']
            cur.execute("CALL CrearCurso(%s, %s, %s, %s, %s, %s)", 
                        (p_codigo_materia, p_seccion, p_fecha_inicio, p_fecha_fin, p_horario, p_email_profesor))
        
        if procedure_name == 'CambiarProfesor':
            p_codigo_materia = request.form['p_codigo_materia']
            p_seccion = request.form['p_seccion']
            p_fecha_inicio = request.form['p_fecha_inicio']
            p_nuevo_email_profesor = request.form['p_nuevo_email_profesor']
            cur.execute("CALL CambiarProfesor(%s, %s, %s, %s)", 
                        (p_codigo_materia, p_seccion, p_fecha_inicio, p_nuevo_email_profesor))
        
        if procedure_name == 'inscribir_estudiante_carrera':
            email_estudiante = request.form['email_estudiante']
            codigo_carrera = request.form['codigo_carrera']
            fecha_inicio = request.form['fecha_inicio']
            cur.execute("CALL inscribir_estudiante_carrera(%s, %s, %s)", 
                        (email_estudiante, codigo_carrera, fecha_inicio))
        
        if procedure_name == 'inscribir_estudiante_curso':
            email_estudiante = request.form['email_estudiante']
            codigo_materia = request.form['codigo_materia']
            seccion = request.form['seccion']
            fecha_inicio = request.form['fecha_inicio']
            cur.execute("CALL inscribir_estudiante_curso(%s, %s, %s, %s)", 
                        (email_estudiante, codigo_materia, seccion, fecha_inicio))
        
        if procedure_name == 'calificar_estudiante':
            email_estudiante = request.form['email_estudiante']
            codigo_materia = request.form['codigo_materia']
            seccion = request.form['seccion']
            nota = request.form['nota']
            fecha_inicio = request.form['fecha_inicio']
            cur.execute("CALL calificar_estudiante(%s, %s, %s, %s, %s)", 
                        (email_estudiante, codigo_materia, seccion, nota, fecha_inicio))
        
        if procedure_name == 'calificar_profesor':
            email_estudiante = request.form['email_estudiante']
            codigo_materia = request.form['codigo_materia']
            seccion = request.form['seccion']
            calificacion_prof = request.form['calificacion_prof']
            fecha_inicio = request.form['fecha_inicio']
            cur.execute("CALL calificar_profesor(%s, %s, %s, %s, %s)", 
                        (email_estudiante, codigo_materia, seccion, calificacion_prof, fecha_inicio))
        
        if procedure_name == 'calificar_materia':
            email_estudiante = request.form['email_estudiante']
            codigo_materia = request.form['codigo_materia']
            seccion = request.form['seccion']
            calificacion_materia = request.form['calificacion_materia']
            fecha_inicio = request.form['fecha_inicio']
            cur.execute("CALL calificar_materia(%s, %s, %s, %s, %s)", 
                        (email_estudiante, codigo_materia, seccion, calificacion_materia, fecha_inicio))
        
        conn.commit()
        cur.close()
        conn.close()
        return redirect(url_for('procedures'))
    
    fields = []
    if procedure_name == 'Crear_Usuario':
        fields = ['email', 'nombre', 'apellido', 'cedula', 'fecha_nacimiento', 'contrasenia']
    if procedure_name == 'Crear_Producto':
        fields = ['nombre', 'stock', 'precio', 'descripcion', 'id_producto']
    if procedure_name == 'Crear_Instrumento':
        fields = ['nombre', 'stock', 'precio', 'descripcion', 'marca', 'modelo', 'categorias']
    if procedure_name == 'Asignar_Categoria_a_Instrumento':
        fields = ['id_instrumento', 'nombre_categoria']
    if procedure_name == 'Crear_CD':
        fields = ['nombre', 'stock', 'precio', 'descripcion', 'tipo', 'discografica', 'nombre_genero', 'nombre_artista']
    if procedure_name == 'Crear_Genero':
        fields = ['id_CD', 'nombre_genero']
    if procedure_name == 'Crear_Artista':
        fields = ['id_CD', 'nombre_artista']
    if procedure_name == 'Crear_Accesorio':
        fields = ['nombre', 'stock', 'precio', 'descripcion', 'marca', 'id_instrumentos']
    if procedure_name == 'Actualizar_Stock':
        fields = ['id_producto', 'valor']
    if procedure_name == 'Actualizar_precio':
        fields = ['id_producto', 'precio']
    if procedure_name == 'Crear_Transaccion':
        fields = ['n_ref', 'email_cliente', 'id_productos', 'cantidades']
    if procedure_name == 'Crear_Profesor':
        fields = ['email', 'cv']
    if procedure_name == 'Crear_Carrera':
        fields = ['codigo_carrera', 'nombre', 'tipo', 'descripcion', 'email_coordinador']
    if procedure_name == 'Crear_Materia':
        fields = ['codigo_materia', 'codigo_carrera', 'nombre', 'nivel', 'categoria']
    if procedure_name == 'Asignar_Categoria_a_Materia':
        fields = ['codigo_materia', 'nombre_categoria']
    if procedure_name == 'Prelar':
        fields = ['codigo_prela', 'codigo_prelada']
    if procedure_name == 'Cambiar_Coordinador':
        fields = ['codigo_carrera', 'email_coordinador']
    if procedure_name == 'Graduarse':
        fields = ['email_estudiante', 'codigo_carrera']
    if procedure_name == 'Crear_Categoria':
        fields = ['nombre']
    if procedure_name == 'Crear_Subcategoria':
        fields = ['categoria_padre', 'categoria_hijo']
    if procedure_name == 'Calificar_Materia':
        fields = ['email_estudiante', 'codigo_materia', 'seccion', 'fecha_inicio', 'calificacion']
    if procedure_name == 'CrearCurso':
        fields = ['p_codigo_materia', 'p_seccion', 'p_fecha_inicio', 'p_fecha_fin', 'p_horario', 'p_email_profesor']
    if procedure_name == 'CambiarProfesor':
        fields = ['p_codigo_materia', 'p_seccion', 'p_fecha_inicio', 'p_nuevo_email_profesor']
    if procedure_name == 'inscribir_estudiante_carrera':
        fields = ['email_estudiante', 'codigo_carrera', 'fecha_inicio']
    if procedure_name == 'inscribir_estudiante_curso':
        fields = ['email_estudiante', 'codigo_materia', 'seccion', 'fecha_inicio']
    if procedure_name == 'calificar_estudiante':
        fields = ['email_estudiante', 'codigo_materia', 'seccion', 'nota', 'fecha_inicio']
    if procedure_name == 'calificar_profesor':
        fields = ['email_estudiante', 'codigo_materia', 'seccion', 'calificacion_prof', 'fecha_inicio']
    if procedure_name == 'calificar_materia':
        fields = ['email_estudiante', 'codigo_materia', 'seccion', 'calificacion_materia', 'fecha_inicio']
    
    return render_template('execute_procedure.html', procedure_name=procedure_name, fields=fields)

@app.route('/execute_function/<function_name>', methods=['GET', 'POST'])
def execute_function(function_name):
    if request.method == 'POST':
        conn = get_db_connection()
        cur = conn.cursor()
        result = []
        if function_name == 'Obtener_Pensum':
            codigo_carrera_entrada = request.form['codigo_carrera_entrada']
            cur.execute("SELECT * FROM Obtener_Pensum(%s)", (codigo_carrera_entrada,))
            result = cur.fetchall()
        
        if function_name == 'Obtener_Registro_Transacciones':
            email_cliente_entrada = request.form['email_cliente_entrada']
            cur.execute("SELECT * FROM Obtener_Registro_Transacciones(%s)", (email_cliente_entrada,))
            result = cur.fetchall()
        
        if function_name == 'Obtener_Productos_Transaccion':
            id_transaccion_entrada = request.form['id_transaccion_entrada']
            cur.execute("SELECT * FROM Obtener_Productos_Transaccion(%s)", (id_transaccion_entrada,))
            result = cur.fetchall()

        if function_name == 'Obtener_Cursos_Activos':
            cur.execute("SELECT * FROM Obtener_Cursos_Activos()")
            result = cur.fetchall()
        
        if function_name == 'Obtener_Instrumento_por_Categoria':
            categoria = request.form['categoria']
            cur.execute("SELECT * FROM Obtener_Instrumento_por_Categoria(%s)", (categoria,))
            result = cur.fetchall()
        
        cur.close()
        conn.close()
        return render_template('execute_function.html', function_name=function_name, result=result)
    
    fields = []
    if function_name == 'Obtener_Pensum':
        fields = ['codigo_carrera_entrada']
    if function_name == 'Obtener_Registro_Transacciones':
        fields = ['email_cliente_entrada']
    if function_name == 'Obtener_Productos_Transaccion':
        fields = ['id_transaccion_entrada']
    if function_name == 'Obtener_Instrumento_por_Categoria':
        fields = ['categoria']
    
    return render_template('execute_function.html', function_name=function_name, fields=fields)

if __name__ == '__main__':
    app.run(debug=True)
