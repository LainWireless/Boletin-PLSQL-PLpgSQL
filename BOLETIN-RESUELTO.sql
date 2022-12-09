# Boletin PLSQL & PLpgSQ

-- 1. Hacer un procedimiento que muestre por pantalla el nombre y el salario del empleado cuyo código es 7782

CREATE OR REPLACE PROCEDURE mostrar_empleado
IS
    v_ename scott.emp.ename%TYPE;
    v_sal scott.emp.sal%TYPE;
BEGIN
    select ename, sal into v_ename, v_sal
    from scott.emp
    where empno = 7782;
    dbms_output.put_line('Nombre: ' || v_ename || ' | Salario: ' || v_sal);
END mostrar_empleado;
/


-- 2. Hacer un procedimiento que reciba como parámetro un código de empleado y devuelva su nombre

CREATE OR REPLACE PROCEDURE mostrar_nombre_empleado (p_codigo_empleado scott.emp.empno%TYPE)
IS
    v_ename scott.emp.ename%TYPE;
BEGIN
    select ename into v_ename
    from scott.emp
    where empno = p_codigo_empleado;
    dbms_output.put_line('Nombre: ' || v_ename);
END mostrar_nombre_empleado;
/



-- 3. Hacer un procedimiento que devuelva los nombres de los tres empleados más antiguos

CREATE OR REPLACE PROCEDURE mostrar_tres_empleados_mas_antiguos
IS
    v_nombre scott.emp.ename%TYPE;
    cursor c_empleados
    is
    select ename
    from scott.emp
    order by hiredate
    fetch first 3 rows only;
BEGIN
    for v_empleado in c_empleados loop
        v_nombre := v_empleado.ename;
        dbms_output.put_line('Nombre: ' || v_nombre);
    end loop;
END mostrar_tres_empleados_mas_antiguos;
/



-- 4. Hacer un procedimiento que reciba el nombre de un tablespace y muestre los nombres de los usuarios que lo tienen como tablespace por defecto (Vista DBA_USERS)

CREATE OR REPLACE PROCEDURE mostrar_usuarios_tablespace (p_nombre_tablespace VARCHAR2)
IS
    v_nombre_usuario dba_users.username%TYPE;
    cursor c_usuarios
    is
    select username
    from dba_users
    where default_tablespace = p_nombre_tablespace;
BEGIN
    for v_usuario in c_usuarios loop
        v_nombre_usuario := v_usuario.username;
        dbms_output.put_line('Usuario: ' || v_nombre_usuario);
    end loop;
END mostrar_usuarios_tablespace;
/



-- 5. Modificar el procedimiento anterior para que haga lo mismo pero devolviendo el número de usuarios que tiene ese tablespace como tablespace por defecto. Nota: Hay que convertir el procedimiento en función

-- Función para listar usuarios:
CREATE OR REPLACE FUNCTION f_mostrar_usuarios_tablespace (p_nombre_tablespace VARCHAR2)
RETURN VARCHAR2
IS
    v_nombre_usuario dba_users.username%TYPE;
    cursor c_usuarios
    is
    select username
    from dba_users
    where default_tablespace = p_nombre_tablespace;
BEGIN
    for v_usuario in c_usuarios loop
        v_nombre_usuario := v_usuario.username;
        dbms_output.put_line('Usuario: ' || v_nombre_usuario);
    end loop;
    RETURN v_nombre_usuario;
END f_mostrar_usuarios_tablespace;
/


-- Función para contar usuarios:
CREATE OR REPLACE FUNCTION f_contar_usuarios_tablespace (p_nombre_tablespace VARCHAR2)
RETURN NUMBER
IS
    v_contador NUMBER := 0;
    cursor c_usuarios
    is
    select username
    from dba_users
    where default_tablespace = p_nombre_tablespace;
BEGIN
    for v_usuario in c_usuarios loop
        v_contador := v_contador + 1;
    end loop;
    RETURN v_contador;
END f_contar_usuarios_tablespace;
/



-- Función que combina las dos anteriores:

CREATE OR REPLACE FUNCTION f_mostrar_usuarios_tablespace_y_total (p_nombre_tablespace VARCHAR2)
RETURN VARCHAR2
IS
    v_listar dba_users.username%TYPE;
    v_total NUMBER;
BEGIN
    v_listar := f_mostrar_usuarios_tablespace(p_nombre_tablespace);
    v_total := f_contar_usuarios_tablespace(p_nombre_tablespace);
    dbms_output.put_line('Total Usuarios Tablespace ' || p_nombre_tablespace || ': ' || v_total);
    RETURN v_listar;
END f_mostrar_usuarios_tablespace_y_total;
/



-- 6. Hacer un procedimiento llamado mostrar_usuarios_por_tablespace que muestre por pantalla un listado de los tablespaces existentes con la lista de usuarios de cada uno y el número de los mismos, así: (Vistas DBA_TABLESPACES y DBA_USERS)
-- Importante: El procedimiento estará formado por estas funciones:
-- f_listar_usuarios_tablespace
-- f_contar_usuarios_tablespace
-- f_mostrar_usuarios_tablespace_y_total
-- f_contar_total_usuarios_BD

--Tablespace xxxx:
--
--	Usr1
--	Usr2
--	...
--
--Total Usuarios Tablespace xxxx: n1

--Tablespace yyyy:
--
--	Usr1
--	Usr2
--	...
--
--Total Usuarios Tablespace yyyy: n2
--....
--Total Usuarios BD: nn


-- Función para contar el total de usuarios de la BD:
CREATE OR REPLACE FUNCTION f_contar_total_usuarios_BD
RETURN NUMBER
IS
    v_contador NUMBER := 0;
    cursor c_usuarios
    is
    select username
    from dba_users;
BEGIN
    for v_usuario in c_usuarios loop
        v_contador := v_contador + 1;
    end loop;
    RETURN v_contador;
END f_contar_total_usuarios_BD;
/


-- Procedimiento que llama a la función anterior y a dos del ejercicio anterior:
CREATE OR REPLACE PROCEDURE mostrar_usuarios_por_tablespace
IS
    v_listar dba_users.username%TYPE;
    v_contar NUMBER;
    v_total NUMBER;
    cursor c_tablespaces
    is
    select tablespace_name
    from dba_tablespaces;
BEGIN
    for v_tablespace in c_tablespaces loop
        dbms_output.put_line('----------------------------------------');
        dbms_output.put_line('Tablespace ' || v_tablespace.tablespace_name || ':');
        v_listar := f_mostrar_usuarios_tablespace(v_tablespace.tablespace_name);
        v_contar := f_contar_usuarios_tablespace(v_tablespace.tablespace_name);
        v_total := f_contar_total_usuarios_BD;
        dbms_output.put_line('Total Usuarios Tablespace ' || v_tablespace.tablespace_name || ': ' || v_contar);
    end loop;
    dbms_output.put_line('----------------------------------------');
    dbms_output.put_line('Total Usuarios BD: ' || v_total);
    dbms_output.put_line('----------------------------------------');
END mostrar_usuarios_por_tablespace;
/



-- 7. Hacer un procedimiento llamado mostrar_codigo_fuente  que reciba el nombre de otro procedimiento y muestre su código fuente. (DBA_SOURCE)

CREATE OR REPLACE PROCEDURE mostrar_codigo_fuente (p_nombre_procedimiento VARCHAR2)
IS
    v_codigo_fuente dba_source.text%TYPE;
    cursor c_codigo
    is
    select text
    from dba_source
    where name = p_nombre_procedimiento;
BEGIN
    for v_codigo in c_codigo loop
        v_codigo_fuente := v_codigo.text;
        dbms_output.put_line(v_codigo_fuente);
    end loop;
END mostrar_codigo_fuente;
/
-- Ejecutar el procedimiento
exec mostrar_codigo_fuente('MOSTRAR_USUARIOS_POR_TABLESPACE');

-- 8. Hacer un procedimiento llamado mostrar_privilegios_usuario que reciba el nombre de un usuario y muestre sus privilegios de sistema junto a la lista de sistemas sobre los que tiene privilegios y sus privilegios sobre objetos junto a la lista de objetos sobre los que tiene privilegios. (DBA_SYS_PRIVS, DBA_TAB_PRIVS, DBA_COL_PRIVS).

-- Función para mostrar los privilegios de sistema de un usuario:
CREATE OR REPLACE FUNCTION f_mostrar_privilegios_sistema_usuario (p_nombre_usuario VARCHAR2)
RETURN VARCHAR2
IS
    v_privilegios dba_sys_privs.privilege%TYPE;
    cursor c_privilegios
    is
    select privilege
    from dba_sys_privs
    where grantee = p_nombre_usuario;
BEGIN
    for v_privilegios in c_privilegios loop
        dbms_output.put_line(v_privilegios.privilege);
    end loop;
    RETURN v_privilegios;
END f_mostrar_privilegios_sistema_usuario;
/


-- Funcion para mostrar los privilegios de objetos de un usuario:
CREATE OR REPLACE FUNCTION f_mostrar_privilegios_objetos_usuario (p_nombre_usuario VARCHAR2)
RETURN VARCHAR2
IS
    v_privilegios dba_tab_privs.privilege%TYPE;
    cursor c_privilegios
    is
    select privilege, table_name
    from dba_tab_privs
    where grantee = p_nombre_usuario;
BEGIN
    for v_privilegios in c_privilegios loop
        dbms_output.put_line(v_privilegios.privilege || ' sobre ' || v_privilegios.table_name);
    end loop;
    RETURN v_privilegios;
END f_mostrar_privilegios_objetos_usuario;
/


-- Procedimiento que combina las dos funciones anteriores:
CREATE OR REPLACE PROCEDURE mostrar_privilegios_usuario (p_nombre_usuario VARCHAR2)
IS
    v_privilegios_sistema dba_sys_privs.privilege%TYPE;
    v_privilegios_objetos dba_tab_privs.privilege%TYPE;
BEGIN
    dbms_output.put_line('----------------------------------------');
    dbms_output.put_line('Privilegios de sistema de ' || p_nombre_usuario || ':');
    v_privilegios_sistema := f_mostrar_privilegios_sistema_usuario(p_nombre_usuario);
    dbms_output.put_line('----------------------------------------');
    dbms_output.put_line('Privilegios de objetos de ' || p_nombre_usuario || ':');
    v_privilegios_objetos := f_mostrar_privilegios_objetos_usuario(p_nombre_usuario);
    dbms_output.put_line('----------------------------------------');
END mostrar_privilegios_usuario;
/



-- 9. Realiza un procedimiento llamado listar_comisiones que nos muestre por pantalla un listado de las comisiones de los empleados agrupados según la localidad donde está ubicado su departamento.
--Nota: Los nombres de localidades, departamentos y empleados deben aparecer por orden alfabético.
--
--Si alguno de los departamentos no tiene ningún empleado con comisiones, aparecerá un mensaje informando de ello en lugar de la lista de empleados.
--
--El procedimiento debe gestionar adecuadamente las siguientes excepciones:
--
--    a) La tabla Empleados está vacía.
--    b) Alguna comisión es mayor que 10000.
--
-- Debe tener el siguiente formato:
--Localidad NombreLocalidad
--	
--Departamento: NombreDepartamento
--
--		Empleado1 ……. Comisión 1
--		Empleado2 ……. Comisión 2
--		.	
--		.
--		.
--		Empleadon ……. Comision n
--
--	Total Comisiones en el Departamento NombreDepartamento: SumaComisiones
--
--	Departamento: NombreDepartamento
--
--		Empleado1 ……. Comisión 1
--		Empleado2 ……. Comisión 2
--		.	
--		.		.
--		Empleadon ……. Comision n
--
--	Total Comisiones en el Departamento NombreDepartamento: SumaComisiones
--	.	
--	.
--Total Comisiones en la Localidad NombreLocalidad: SumaComisionesLocalidad
--
--Localidad NombreLocalidad
--.
--.
--
--Total Comisiones en la Empresa: TotalComisiones



-- Procedimiento para la excepción de commprobar si la tabla empleados está vacía:
CREATE OR REPLACE PROCEDURE ComprobarTablasVacias
IS 
    v_numemp NUMBER:=0;
BEGIN 
    SELECT count (*) INTO v_numemp FROM SCOTT.EMP;
    IF v_numemp = 0 THEN
        raise_application_error(-20001,'No hay empleados en la tabla empleados.');
    END IF;
END ComprobarTablasVacias;
/


-- Procedimiento para la excepción de comprobar si alguna comisión es mayor que 10000:
CREATE OR REPLACE PROCEDURE ComprobarComisiones
IS
    v_comision NUMBER:=0;
BEGIN
    SELECT count(*) INTO v_comision FROM SCOTT.EMP WHERE comm > 10000;
    IF v_comision > 0 THEN
        raise_application_error(-20002,'Hay comisiones mayores de 10000.');
    END IF;
END ComprobarComisiones;
/


-- Procedimiento para listar los empleados:
CREATE OR REPLACE PROCEDURE ListarEmpleados (p_deptno scott.dept.loc%TYPE)
IS
    cursor c_emp IS SELECT ename,comm FROM scott.emp 
    WHERE deptno IN (SELECT deptno FROM scott.dept WHERE dname = p_deptno) ORDER BY ename asc;
    v_emp number:=0;
BEGIN
    SELECT sum(comm) INTO v_emp FROM scott.emp WHERE deptno IN (SELECT deptno FROM scott.dept WHERE dname = p_deptno);
    IF v_emp IS NULL THEN
        dbms_output.put_line(chr(9)||chr(9)||'No hay empleados con comision.');
    ELSE
        FOR v_empleado in c_emp LOOP
            dbms_output.put_line(chr(9)||chr(9)||v_empleado.ename||'..........'||v_empleado.comm);
        END LOOP;
    END IF;
END ListarEmpleados;
/


-- Procedimiento para listar comisiones totales de los departamentos:
CREATE OR REPLACE PROCEDURE TotalComisionesDept (p_dept scott.dept.dname%TYPE)
IS
    v_totaldept number:=0;
BEGIN
    SELECT sum(comm) INTO v_totaldept FROM scott.emp 
    WHERE DEPTNO IN (SELECT deptno FROM scott.dept WHERE dname = p_dept);
    IF v_totaldept IS NULL THEN
        dbms_output.put_line(chr(9)||'Total Comisiones en el Departamento '||p_dept||': NULL'||chr(10));
    ELSE
        dbms_output.put_line(chr(9)||'Total Comisiones en el Departamento '||p_dept||': '||v_totaldept||chr(10));
    END IF;
END TotalComisionesDept;
/


-- Procedimiento para listar los departamentos:
CREATE OR REPLACE PROCEDURE ListarDepartamentos (p_loc scott.dept.loc%TYPE)
IS
    cursor c_dept IS SELECT dname FROM scott.dept WHERE loc = p_loc;
BEGIN
    FOR v_dept in c_dept LOOP
        dbms_output.put_line(chr(9)||'Departamento: '||v_dept.dname);
        ListarEmpleados(v_dept.dname);
        TotalComisionesDept(v_dept.dname);
    END LOOP;
END ListarDepartamentos;
/


-- Procedimiento para listar comisiones totales de las localidades:
CREATE OR REPLACE PROCEDURE TotalComisionesLoc (p_loc scott.dept.loc%TYPE)
IS
    v_totalloc number:=0;
BEGIN
    SELECT sum(comm) INTO v_totalloc FROM scott.emp 
    WHERE DEPTNO IN (SELECT deptno FROM scott.dept WHERE loc = p_loc);
    IF v_totalloc IS NULL THEN
        dbms_output.put_line('Total Comisiones en la Localidad '||p_loc||': NULL'||chr(10));
    ELSE
        dbms_output.put_line('Total Comisiones en la Localidad '||p_loc||': '||v_totalloc||chr(10));
    END IF;
END TotalComisionesLoc;
/


-- Procedimiento para listar comisiones totales de la empresa:
CREATE OR REPLACE PROCEDURE TotalComisionesEmpresa
IS
    v_totalempresa number:=0;
BEGIN
    SELECT sum(comm) INTO v_totalempresa FROM scott.emp;
    dbms_output.put_line('Total Comisiones en la Empresa: '||v_totalempresa);
END;
/


-- Procedimiento principal
CREATE OR REPLACE PROCEDURE ListarComisiones
IS
    cursor c_loc IS SELECT loc FROM scott.dept GROUP BY loc ORDER BY loc asc;
BEGIN
    ComprobarTablasVacias;
    ComprobarComisiones;
    FOR v_loc in c_loc LOOP
        dbms_output.put_line('----------------------------------------------------------------------');
        dbms_output.put_line('Localidad '||v_loc.loc);
        ListarDepartamentos(v_loc.loc);
        TotalComisionesLoc(v_loc.loc);        
    END LOOP;
    dbms_output.put_line('----------------------------------------------------------------------');
    TotalComisionesEmpresa;
    dbms_output.put_line('----------------------------------------------------------------------');
END ListarComisiones;
/




-- 10. Realiza un procedimiento que reciba el nombre de una tabla y muestre los nombres de las restricciones que tiene, a qué columna afectan y en qué consisten exactamente. (DBA_TABLES, DBA_CONSTRAINTS, DBA_CONS_COLUMNS)

-- Procedimiento:
CREATE OR REPLACE PROCEDURE listar_restricciones (p_tabla varchar2)
IS
    cursor c_tabla is
    SELECT a.constraint_name, b.column_name, a.constraint_type
    FROM dba_constraints a, dba_cons_columns b, dba_tables c
    WHERE a.constraint_name = b.constraint_name
    AND a.table_name = c.table_name
    AND a.table_name = p_tabla;
BEGIN
    for v_tabla in c_tabla loop
        dbms_output.put_line('-----------------------------------');
        dbms_output.put_line('Tabla: ' || p_tabla);
        dbms_output.put_line('Restriccion: ' || v_tabla.constraint_name);
        dbms_output.put_line('Columna: ' || v_tabla.column_name);
        dbms_output.put_line('Descripcion: ' || v_tabla.constraint_type);
    end loop;
END listar_restricciones;
/



-- 11. Realiza al menos dos de los ejercicios anteriores en Postgres usando PL/pgSQL.
-- 11.1. Hacer un procedimiento que muestre el nombre y el salario del empleado cuyo código es 7782
CREATE OR REPLACE FUNCTION mostrar_empleado() RETURNS void 
AS $$
DECLARE
    v_ename scott.emp.ename%TYPE;
    v_sal scott.emp.sal%TYPE;
BEGIN
    select ename, sal into v_ename, v_sal
    from scott.emp
    where empno = 7782;
    raise notice '%','Nombre: ' || v_ename || ' | Salario: ' || v_sal;
END;
$$ LANGUAGE plpgsql;



-- 11.2. Recrear el ejercicio de Listado de Comisiones.
-- Función ComprobarTablasVacias:
CREATE OR REPLACE FUNCTION ComprobarTablasVacias() RETURNS VOID
AS $$
DECLARE 
    v_numemp INT=0;
BEGIN 
    SELECT count (*) INTO v_numemp FROM SCOTT.EMP;
    IF v_numemp = 0 THEN
        RAISE EXCEPTION 'No hay empleados en la tabla empleados.';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Función ComprobarComisiones:
CREATE OR REPLACE FUNCTION ComprobarComisiones() RETURNS VOID
AS $$
DECLARE
    v_comision INT=0;
BEGIN
    SELECT count(*) INTO v_comision FROM SCOTT.EMP WHERE comm > 10000;
    IF v_comision > 0 THEN
        RAISE EXCEPTION 'Hay comisiones mayores de 10000.';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Función ListarEmpleados:
CREATE OR REPLACE FUNCTION ListarEmpleados (p_deptno scott.dept.loc%TYPE) RETURNS VOID
AS $$
DECLARE
    c_emp cursor FOR SELECT ename,comm FROM scott.emp 
    WHERE deptno IN (SELECT deptno FROM scott.dept WHERE dname = p_deptno) ORDER BY ename asc;
    v_emp int=0;
BEGIN
    SELECT sum(comm) INTO v_emp FROM scott.emp WHERE deptno IN (SELECT deptno FROM scott.dept WHERE dname = p_deptno);
    IF v_emp IS NULL THEN
        raise notice '%',chr(9)||chr(9)||'No hay empleados con comision.';
    ELSE
        FOR v_empleado in c_emp LOOP
            raise notice '%',chr(9)||chr(9)||v_empleado.ename||'..........'||v_empleado.comm;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Función TotalComisionesDept:
CREATE OR REPLACE FUNCTION TotalComisionesDept (p_dept scott.dept.dname%TYPE) RETURNS VOID
AS $$
DECLARE
    v_totaldept int=0;
BEGIN
    SELECT sum(comm) INTO v_totaldept FROM scott.emp 
    WHERE DEPTNO IN (SELECT deptno FROM scott.dept WHERE dname = p_dept);
    IF v_totaldept IS NULL THEN
        raise notice '%',chr(9)||'Total Comisiones en el Departamento '||p_dept||': NULL'||chr(10);
    ELSE
        raise notice '%',chr(9)||'Total Comisiones en el Departamento '||p_dept||': '||v_totaldept||chr(10);
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Función ListarDepartamentos:
CREATE OR REPLACE FUNCTION ListarDepartamentos (p_loc scott.dept.loc%TYPE) RETURNS VOID
AS $$
DECLARE
    c_dept cursor FOR SELECT dname FROM scott.dept WHERE loc = p_loc;
BEGIN
    FOR v_dept in c_dept LOOP
        raise notice '%',chr(9)||'Departamento: '||v_dept.dname;
        PERFORM ListarEmpleados(v_dept.dname);
        PERFORM TotalComisionesDept(v_dept.dname);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Función TotalComisionesLoc:
CREATE OR REPLACE FUNCTION TotalComisionesLoc (p_loc scott.dept.loc%TYPE) RETURNS VOID
AS $$
DECLARE
    v_totalloc int=0;
BEGIN
    SELECT sum(comm) INTO v_totalloc FROM scott.emp 
    WHERE DEPTNO IN (SELECT deptno FROM scott.dept WHERE loc = p_loc);
    IF v_totalloc IS NULL THEN
        raise notice '%','Total Comisiones en la Localidad '||p_loc||': NULL'||chr(10);
    ELSE
        raise notice '%','Total Comisiones en la Localidad '||p_loc||': '||v_totalloc||chr(10);
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Función TotalComisionesEmpresa:
CREATE OR REPLACE FUNCTION TotalComisionesEmpresa() RETURNS VOID
AS $$
DECLARE
    v_totalempresa int=0;
BEGIN
    SELECT sum(comm) INTO v_totalempresa FROM scott.emp;
    raise notice '%','Total Comisiones en la Empresa: '||v_totalempresa;
END;
$$ LANGUAGE plpgsql;


-- Función principal:
CREATE OR REPLACE FUNCTION ListarComisiones() RETURNS VOID
AS $$
DECLARE
    c_loc cursor FOR SELECT loc FROM scott.dept GROUP BY loc ORDER BY loc asc;
BEGIN
    FOR v_loc in c_loc LOOP
        raise notice '%','----------------------------------------------------------------------';
        raise notice '%','Localidad '||v_loc.loc;
        PERFORM ListarDepartamentos(v_loc.loc);
        PERFORM TotalComisionesLoc(v_loc.loc);        
    END LOOP;
    raise notice '%','----------------------------------------------------------------------';
    PERFORM TotalComisionesEmpresa();
    raise notice '%','----------------------------------------------------------------------';
END;
$$ LANGUAGE plpgsql;





