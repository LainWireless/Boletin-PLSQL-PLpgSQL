-- creación de la base de datos scott:
CREATE DATABASE scott;

-- creación del usuario scott y ortorgación de permisos sobre la base de datos scott:
create user scott with password 'tiger';
grant all privileges on database scott to scott;

-- creación del esquema scott:
CREATE SCHEMA scott AUTHORIZATION scott;

-- creación de tablas:
CREATE TABLE scott.dept
(
  deptno integer NOT NULL,
  dname character varying(14) NOT NULL,
  loc character varying(13) NOT NULL,
  CONSTRAINT dept_pkey PRIMARY KEY (deptno)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE scott.dept
  OWNER TO scott;

CREATE TABLE scott.emp
(
  empno integer NOT NULL,
  ename character varying(10) NOT NULL,
  job character varying(9) NOT NULL,
  mgr integer,
  hiredate date NOT NULL,
  sal numeric(7,2),
  comm numeric(7,2),
  deptno integer NOT NULL,
  CONSTRAINT emp_pkey PRIMARY KEY (empno),
  CONSTRAINT emp_deptno_fkey FOREIGN KEY (deptno)
      REFERENCES scott.dept (deptno) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE scott.emp
  OWNER TO scott;


-- inserts:
INSERT INTO scott.dept VALUES (10,'ACCOUNTING','NEW YORK');
INSERT INTO scott.dept VALUES (20,'RESEARCH','DALLAS');
INSERT INTO scott.dept VALUES (30,'SALES','CHICAGO');
INSERT INTO scott.dept VALUES (40,'OPERATIONS','BOSTON');

INSERT INTO scott.emp VALUES (7369,'SMITH','CLERK',7902,'1980-12-17',800,NULL,20);
INSERT INTO scott.emp VALUES (7499,'ALLEN','SALESMAN',7698,'1981-02-20',1600,300,30);
INSERT INTO scott.emp VALUES (7521,'WARD','SALESMAN',7698,'1981-02-22',1250,500,30);
INSERT INTO scott.emp VALUES (7566,'JONES','MANAGER',7839,'1981-04-02',2975,NULL,20);
INSERT INTO scott.emp VALUES (7654,'MARTIN','SALESMAN',7698,'1981-09-28',1250,1400,30);
INSERT INTO scott.emp VALUES (7698,'BLAKE','MANAGER',7839,'1981-05-01',2850,NULL,30);
INSERT INTO scott.emp VALUES (7782,'CLARK','MANAGER',7839,'1981-06-09',2450,NULL,10);
INSERT INTO scott.emp VALUES (7788,'SCOTT','ANALYST',7566,'1987-04-19',3000,NULL,20);
INSERT INTO scott.emp VALUES (7839,'KING','PRESIDENT',NULL,'1981-11-17',5000,NULL,10);




