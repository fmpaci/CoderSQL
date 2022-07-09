DROP DATABASE IF EXISTS correcciones_31260;
CREATE DATABASE correcciones_31260;
USE correcciones_31260;

DELIMITER $USD
CREATE PROCEDURE correcciones_31260.CREAR_ESCTRUCTURA()
BEGIN

    DROP TABLE IF EXISTS correcciones_31260.analisis_general_objetos;
    CREATE TABLE IF NOT EXISTS correcciones_31260.analisis_general_objetos(
         ORDEN INT
        ,OBJETO VARCHAR(250)
        ,CANT_ACTUAL  INT
        ,CANT_MINIMA INT
        ,CANT_OPTIMA INT
        ,INFO_EXTRA VARCHAR(5000)
    );

        INSERT INTO correcciones_31260.analisis_general_objetos VALUES
            (10,'TABLAS', 0, 12, 15, ''),
            (20,'TABLAS REFERENCIADAS (FK)', 0, 5, 8, ''),
            (30,'TABLAS HIJAS', 0, 5, 10, ''),
            (40,'VISTAS', 0, 5, 8, ''),
            (50,'TRIGGERS', 0, 3, 8, ''),
            (60,'FUNCIONES', 0, 3, 8, ''),
            (70,'PROCEDURES', 0, 3, 8, '');

    DROP TABLE IF EXISTS correcciones_31260.analisis_tablas;
    CREATE TABLE IF NOT EXISTS correcciones_31260.analisis_tablas
    (
        ORDEN       INT
        ,TABLA      VARCHAR(250)
        ,COLUMNAS   INT
        ,TIENE_PK   INT
        ,DESC_PK    VARCHAR(500)
        ,TIENE_FK   INT
        ,DESC_FK    VARCHAR(500)
        ,TIENE_TG   INT
        ,DESC_TG    VARCHAR(500)
        ,INFO_EXTRA VARCHAR(500)
        ,SELECT_SCR VARCHAR(1000)
        ,INSERT_SCR VARCHAR(1000)
        ,DELETE_SCR VARCHAR(1000)
    );

    DROP TABLE IF EXISTS correcciones_31260.notas;
    create table correcciones_31260.notas (
          objeto varchar(20)
        , cantidad int
        , nota int
    );

    INSERT INTO correcciones_31260.notas
    VALUES  ('TABLAS',12,7),
            ('TABLAS',13,8),
            ('TABLAS',14,9),
            ('TABLAS',15,10);

    INSERT INTO correcciones_31260.notas
        VALUES  ('TABLAS REFERENCIADAS',5,7),
                ('TABLAS REFERENCIADAS',6,8),
                ('TABLAS REFERENCIADAS',7,9),
                ('TABLAS REFERENCIADAS',8,10);

    INSERT INTO correcciones_31260.notas
        VALUES  ('VISTAS',5,7),
                ('VISTAS',6,8),
                ('VISTAS',7,9),
                ('VISTAS',8,10);


    INSERT INTO correcciones_31260.notas
        VALUES  ('TRIGGERS',3,7),
                ('TRIGGERS',4,8),
                ('TRIGGERS',5,9),
                ('TRIGGERS',6,10);


    INSERT INTO correcciones_31260.notas
        VALUES  ('FUNCIONES',3,7),
                ('FUNCIONES',4,8),
                ('FUNCIONES',5,9),
                ('FUNCIONES',6,10);

    INSERT INTO correcciones_31260.notas
        VALUES  ('PROCEDURES',4,7),
                ('PROCEDURES',5,8),
                ('PROCEDURES',6,9),
                ('PROCEDURES',7,10);


    DROP TABLE IF EXISTS correcciones_31260.analisis_tablas;
    CREATE TABLE IF NOT EXISTS correcciones_31260.analisis_tablas
    (
        ORDEN       INT
        ,TABLA      VARCHAR(250)
        ,COLUMNAS   INT
        ,TIENE_PK   INT
        ,DESC_PK    VARCHAR(500)
        ,TIENE_FK   INT
        ,DESC_FK    VARCHAR(500)
        ,TIENE_TG   INT
        ,DESC_TG    VARCHAR(500)
        ,INFO_EXTRA VARCHAR(500)
        ,SELECT_SCR VARCHAR(1000)
        ,INSERT_SCR VARCHAR(1000)
        ,DELETE_SCR VARCHAR(1000)
    );

    DROP TABLE IF EXISTS correcciones_31260.analisis_vistas;
    CREATE TABLE IF NOT EXISTS correcciones_31260.analisis_vistas
    (
        ORDEN           INT
        ,vista          VARCHAR(250)
        ,definicion     varchar(5000)
        ,TIENE_GROUP_BY INT
        ,TIENE_JOINS    INT
        ,TIENE_UDF      INT
        ,UDFS_DESC      VARCHAR(200)
        ,SELECT_SCR     VARCHAR(1000)
    );

END $USD
DELIMITER ;

DELIMITER $USD
drop procedure IF EXISTS correcciones_31260.ANALIZAR_BASE$USD
CREATE PROCEDURE correcciones_31260.ANALIZAR_BASE(BASE VARCHAR(250))
BEGIN
    -- VALIDA QUE EXISTAN LAS TABLAS NECESARIAS PARA GUARDAR LA INFORMACION
    CALL correcciones_31260.CREAR_ESCTRUCTURA();
    /*IF 3 <> (SELECT SUM(1) FROM information_schema.tables
                WHERE table_schema = 'correcciones_31260'
                AND table_name IN ('analisis_general_objetos','analisis_tablas','analisis_vistas')
            ) then
        CALL correcciones_31260.CREAR_ESCTRUCTURA();
    END IF;
    */
    IF EXISTS (select 1 from information_schema.tables where table_schema = BASE) then
        CALL correcciones_31260.ANALIZAR_OBJETOS(BASE);
        CALL correcciones_31260.ANALIZAR_TABLAS(BASE);
        CALL correcciones_31260.ANALIZAR_VISTAS(BASE);



        CALL correcciones_31260.ANALIZAR_PROCEDURES(BASE);
        call correcciones_31260.ANALIZAR_FUNCIONES(BASE);
        CALL correcciones_31260.ANALIZAR_TRIGGERS(BASE);

        SELECT ORDEN, OBJETO, info_extra
             , CASE WHEN objeto = 'TABLAS' AND cant_actual < 12 THEN 6
                    WHEN objeto = 'TABLAS' AND cant_actual = 12 THEN 7
                    WHEN objeto = 'TABLAS' AND cant_actual = 13 THEN 8
                    WHEN objeto = 'TABLAS' AND cant_actual = 14 THEN 9
                    WHEN objeto = 'TABLAS' AND cant_actual >= 15 THEN 10

                    WHEN objeto = 'TABLAS REFERENCIADAS (FK)' AND cant_actual < 5 THEN 6
                    WHEN objeto = 'TABLAS REFERENCIADAS (FK)' AND cant_actual = 5 THEN 7
                    WHEN objeto = 'TABLAS REFERENCIADAS (FK)' AND cant_actual = 6 THEN 8
                    WHEN objeto = 'TABLAS REFERENCIADAS (FK)' AND cant_actual = 7 THEN 9
                    WHEN objeto = 'TABLAS REFERENCIADAS (FK)' AND cant_actual >= 8 THEN 10

                    WHEN objeto = 'VISTAS' AND cant_actual < 5 THEN 6
                    WHEN objeto = 'VISTAS' AND cant_actual = 5 THEN 7
                    WHEN objeto = 'VISTAS' AND cant_actual = 6 THEN 8
                    WHEN objeto = 'VISTAS' AND cant_actual = 7 THEN 9
                    WHEN objeto = 'VISTAS' AND cant_actual >= 8 THEN 10

                     WHEN objeto = 'TRIGGERS' AND cant_actual < 3 THEN 6
                    WHEN objeto = 'TRIGGERS' AND cant_actual = 3 THEN 7
                    WHEN objeto = 'TRIGGERS' AND cant_actual = 4 THEN 8
                    WHEN objeto = 'TRIGGERS' AND cant_actual = 5 THEN 9
                    WHEN objeto = 'TRIGGERS' AND cant_actual >= 6 THEN 10

                     WHEN objeto = 'FUNCIONES' AND cant_actual < 3 THEN 6
                    WHEN objeto = 'FUNCIONES' AND cant_actual = 3 THEN 7
                    WHEN objeto = 'FUNCIONES' AND cant_actual = 4 THEN 8
                    WHEN objeto = 'FUNCIONES' AND cant_actual = 5 THEN 9
                    WHEN objeto = 'FUNCIONES' AND cant_actual >= 6 THEN 10

                    WHEN objeto = 'PROCEDURES' AND cant_actual < 3 THEN 6
                    WHEN objeto = 'PROCEDURES' AND cant_actual = 3 THEN 7
                    WHEN objeto = 'PROCEDURES' AND cant_actual = 4 THEN 8
                    WHEN objeto = 'PROCEDURES' AND cant_actual = 5 THEN 9
                    WHEN objeto = 'PROCEDURES' AND cant_actual >= 6 THEN 10
                END NOTA_OBJETO
        FROM correcciones_31260.analisis_general_objetos
        UNION
        SELECT 9999, 'NOTA MAXIMA FINAL','', AVG(CASE WHEN objeto = 'TABLAS' AND cant_actual < 12 THEN 6
                    WHEN objeto = 'TABLAS' AND cant_actual = 12 THEN 7
                    WHEN objeto = 'TABLAS' AND cant_actual = 13 THEN 8
                    WHEN objeto = 'TABLAS' AND cant_actual = 14 THEN 9
                    WHEN objeto = 'TABLAS' AND cant_actual >= 15 THEN 10

                    WHEN objeto = 'TABLAS REFERENCIADAS (FK)' AND cant_actual < 5 THEN 6
                    WHEN objeto = 'TABLAS REFERENCIADAS (FK)' AND cant_actual = 5 THEN 7
                    WHEN objeto = 'TABLAS REFERENCIADAS (FK)' AND cant_actual = 6 THEN 8
                    WHEN objeto = 'TABLAS REFERENCIADAS (FK)' AND cant_actual = 7 THEN 9
                    WHEN objeto = 'TABLAS REFERENCIADAS (FK)' AND cant_actual >= 8 THEN 10

                    WHEN objeto = 'VISTAS' AND cant_actual < 5 THEN 6
                    WHEN objeto = 'VISTAS' AND cant_actual = 5 THEN 7
                    WHEN objeto = 'VISTAS' AND cant_actual = 6 THEN 8
                    WHEN objeto = 'VISTAS' AND cant_actual = 7 THEN 9
                    WHEN objeto = 'VISTAS' AND cant_actual >= 8 THEN 10

                     WHEN objeto = 'TRIGGERS' AND cant_actual < 3 THEN 6
                    WHEN objeto = 'TRIGGERS' AND cant_actual = 3 THEN 7
                    WHEN objeto = 'TRIGGERS' AND cant_actual = 4 THEN 8
                    WHEN objeto = 'TRIGGERS' AND cant_actual = 5 THEN 9
                    WHEN objeto = 'TRIGGERS' AND cant_actual >= 6 THEN 10

                     WHEN objeto = 'FUNCIONES' AND cant_actual < 3 THEN 6
                    WHEN objeto = 'FUNCIONES' AND cant_actual = 3 THEN 7
                    WHEN objeto = 'FUNCIONES' AND cant_actual = 4 THEN 8
                    WHEN objeto = 'FUNCIONES' AND cant_actual = 5 THEN 9
                    WHEN objeto = 'FUNCIONES' AND cant_actual >= 6 THEN 10

                    WHEN objeto = 'PROCEDURES' AND cant_actual < 3 THEN 6
                    WHEN objeto = 'PROCEDURES' AND cant_actual = 3 THEN 7
                    WHEN objeto = 'PROCEDURES' AND cant_actual = 4 THEN 8
                    WHEN objeto = 'PROCEDURES' AND cant_actual = 5 THEN 9
                    WHEN objeto = 'PROCEDURES' AND cant_actual >= 6 THEN 10
                END ) NOTA_FINAL
        FROM correcciones_31260.analisis_general_objetos
        GROUP BY 1,2;

        SELECT * FROM correcciones_31260.analisis_tablas;
        SELECT * FROM correcciones_31260.analisis_vistas;
    ELSE
        SELECT 'NO SE ENCUENTRA LA BASE ESPECIFICADA, ANALISIS ABORTADO';
    END IF;
END $USD


CREATE PROCEDURE ANALIZAR_OBJETOS(BASE VARCHAR(250))
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE table_name = 'ANALISIS_GENERAL_OBJETOS') THEN
        WITH ANALISIS_OBJETOS AS (
            SELECT 'TABLAS' AS OBJETO , COUNT(*) AS CANT, GROUP_CONCAT(DISTINCT table_name ORDER BY table_name ASC SEPARATOR ', ') AS INFO_EXTRA
            FROM information_schema.tables
            WHERE table_schema = BASE
                AND TABLE_TYPE = 'BASE TABLE'
            GROUP BY 1
            UNION ALL
            SELECT
              'TABLAS REFERENCIADAS (FK)', COUNT(DISTINCT REFERENCED_TABLE_NAME) AS CANT, GROUP_CONCAT(DISTINCT REFERENCED_TABLE_NAME ORDER BY REFERENCED_TABLE_NAME ASC SEPARATOR ', ')
            -- SELECT *
            FROM
              INFORMATION_SCHEMA.KEY_COLUMN_USAGE
            WHERE constraint_schema = BASE
                AND REFERENCED_TABLE_NAME IS NOT NULL
            GROUP BY 1

            UNION ALL
            SELECT 'VISTAS' AS OBJETO , COUNT(*) AS CANT, GROUP_CONCAT(DISTINCT TABLE_NAME ORDER BY TABLE_NAME ASC SEPARATOR ', ')
            FROM information_schema.tables
            WHERE table_schema = BASE
                AND TABLE_TYPE = 'VIEW'
            GROUP BY 1

            UNION ALL
            SELECT 'TRIGGERS', COUNT(*) AS CANT, GROUP_CONCAT(DISTINCT TRIGGER_NAME ORDER BY event_object_table, TRIGGER_NAME SEPARATOR ', ')
            FROM information_schema.triggers
            WHERE trigger_schema = BASE
            GROUP BY 1

            UNION ALL
            SELECT 'FUNCIONES', COUNT(*) AS CANT, GROUP_CONCAT( ROUTINE_NAME ORDER BY ROUTINE_NAME SEPARATOR ', ')
            FROM information_schema.routines
            WHERE routine_schema = BASE
                AND ROUTINE_TYPE = 'FUNCTION'

            UNION ALL
            SELECT 'PROCEDURES', COUNT(*) AS CANT, GROUP_CONCAT( ROUTINE_NAME ORDER BY ROUTINE_NAME SEPARATOR ', ')
            FROM information_schema.routines
            WHERE routine_schema = BASE
                AND ROUTINE_TYPE = 'PROCEDURE'
        )
        UPDATE correcciones_31260.analisis_general_objetos A
            INNER JOIN ANALISIS_OBJETOS B ON A.OBJETO = B.OBJETO
            SET A.CANT_ACTUAL = COALESCE(B.CANT,0)
                ,A.INFO_EXTRA = B.INFO_EXTRA
        WHERE 1=1
        ;
    END IF;
END $USD
DELIMITER ;

DELIMITER $USD
DROP PROCEDURE IF EXISTS correcciones_31260.ANALIZAR_TABLAS$USD
CREATE PROCEDURE correcciones_31260.ANALIZAR_TABLAS(BASE VARCHAR(250))
BEGIN
    DECLARE _INT INT;
    DECLARE _DEC DECIMAL(5,2);
    DECLARE _CHAR VARCHAR(20);
    DECLARE _DATE DATE;
    DECLARE _TIME TIME;
    DECLARE _TIMESTAMP TIMESTAMP;

    SET _INT = 8;
    SET _DEC = 8.8;
    SET _CHAR = 'CHR VAL 8';
    SET _DATE = '2022-08-08';
    SET _TIME = '20:20';
    SET _TIMESTAMP = CURRENT_TIMESTAMP();

    IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE table_name = 'ANALISIS_TABLAS') THEN
        INSERT INTO ANALISIS_TABLAS (ORDEN,TABLA,COLUMNAS,TIENE_PK,DESC_PK,TIENE_FK,DESC_FK,TIENE_TG,DESC_TG,INFO_EXTRA)
        WITH TABLAS AS (
                SELECT
                    ROW_NUMBER() OVER (ORDER BY T.TABLE_NAME) ORDEN
                    , T.TABLE_NAME
                    , REGEXP_replace(table_NAME, '[a-zA-Z0-9_]','') bad_characters
                FROM information_schema.tables t
                where t.table_schema = BASE
                    and t.TABLE_TYPE = 'BASE TABLE'
            )
            , COLUMNAS AS (
                SELECT
                      C.table_name
                    , COUNT(*) CANT_COLUMNAS
                    , SUM(CASE WHEN C.COLUMN_KEY = 'PRI' THEN 1 ELSE 0 END) AS CANT_PK
                    , TRIM(GROUP_CONCAT(CASE WHEN C.COLUMN_KEY = 'PRI' THEN COLUMN_NAME ELSE NULL END ORDER BY ORDINAL_POSITION SEPARATOR ',')) AS DESC_PK
                    , correcciones_31260.VALIDA_NOMBRES(GROUP_CONCAT(C.COLUMN_NAME separator '')) AS CARACTERES_ERRONEOS
                  --  , GROUP_CONCAT(C.COLUMN_NAME separator '') cosas_raras
                   -- , TRIM(REPLACE(' ',GROUP_CONCAT(DISTINCT REGEXP_replace(COLUMN_NAME, '[a-zA-Z0-9_]','') SEPARATOR ''), '(ESPACIOS)')) CARACTERES_ERRONEOS
                 /* , DATA_TYPE
                    , CHARACTER_MAXIMUM_LENGTH
                    , NUMERIC_PRECISION, NUMERIC_SCALE
                 */
                FROM INFORMATION_SCHEMA.columns c
                    JOIN information_schema.tables t
                        ON t.table_schema = C.table_schema
                        and t.TABLE_TYPE = 'BASE TABLE'
                        AND T.table_name = C.table_name
                WHERE C.table_schema =  BASE
                GROUP BY 1

            )
            , CLAVES_FORANEAS AS (
                SELECT
                    TABLE_NAME
                    , COUNT(*) CANT_FK
                    , GROUP_CONCAT(CONCAT(COLUMN_NAME, '-->', REFERENCED_TABLE_NAME, '.', REFERENCED_COLUMN_NAME) SEPARATOR ', ') DESC_FK
                FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU
                WHERE constraint_schema = BASE
                    AND REFERENCED_TABLE_NAME IS NOT NULL
                GROUP BY 1
            )
            , TRIGGERS AS (
                select
                    event_object_table AS TABLE_NAME
                    , event_manipulation
                    , count(*) AS CANT_TG
                FROM  INFORMATION_SCHEMA.TRIGGERS TG
                where trigger_schema = BASE
                    AND event_object_schema = BASE
                group by 1,2
            )
        SELECT
             ORDEN
            ,T.table_name
            ,C.CANT_COLUMNAS
            ,C.CANT_PK
            ,C.DESC_PK
            ,F.CANT_FK
            ,F.DESC_FK
            ,SUM(TG.CANT_TG)
            ,GROUP_CONCAT(CONCAT(TG.EVENT_MANIPULATION, ': ', TG.CANT_TG))
            ,C.CARACTERES_ERRONEOS
        FROM TABLAS T
            JOIN COLUMNAS C ON T.table_name = C.table_name
            LEFT JOIN CLAVES_FORANEAS F ON T.table_name = F.TABLE_NAME
            LEFT JOIN TRIGGERS TG ON T.table_name = TG.table_name
        GROUP BY ORDEN, T.table_name, C.CANT_COLUMNAS, C.CANT_PK, C.DESC_PK, F.CANT_FK, F.DESC_FK , C.CARACTERES_ERRONEOS;


        UPDATE correcciones_31260.analisis_tablas
        SET SELECT_SCR = CONCAT('SELECT * FROM `', BASE, '`.`', tabla, '`;')
        WHERE 1=1;
        /*
        WITH PKS AS (
             SELECT
                      C.table_name
                    , COUNT(*) CANT_COLUMNAS
                    , SUM(CASE WHEN C.COLUMN_KEY = 'PRI' THEN 1 ELSE 0 END) AS CANT_PK
                    , TRIM(GROUP_CONCAT(CASE WHEN C.COLUMN_KEY = 'PRI' THEN COLUMN_NAME ELSE NULL END ORDER BY ORDINAL_POSITION SEPARATOR ',')) AS DESC_PK
                    , TRIM(REPLACE(' ',GROUP_CONCAT(DISTINCT REGEXP_replace(COLUMN_NAME, '[a-zA-Z0-9_]','') SEPARATOR ''), '(ESPACIOS)')) CARACTERES_ERRONEOS
                  , DATA_TYPE
                    , CHARACTER_MAXIMUM_LENGTH
                    , NUMERIC_PRECISION, NUMERIC_SCALE

                FROM INFORMATION_SCHEMA.columns c
                    JOIN information_schema.tables t
                        ON t.table_schema = C.table_schema
                        and t.TABLE_TYPE = 'BASE TABLE'
                        AND T.table_name = C.table_name
                WHERE C.table_schema =  BASE
                GROUP BY 1
            )
        INSERT_SCR
        DELETE_SCR
        */
    END IF;
END $USD
DELIMITER ;


DELIMITER $USD
DROP FUNCTION IF EXISTS correcciones_31260.REFORMAT_VIEWS$USD

CREATE  FUNCTION correcciones_31260.REFORMAT_VIEWS (view_definition varchar(5000))
returns varchar(5000)
NO SQL
BEGIN
    DECLARE CLEAN_VIEW VARCHAR(5000);
    SET CLEAN_VIEW =
        replace(
                replace(
                    replace(
                        replace(
                            replace(
                                replace(
                                    replace(
                                        replace(view_definition,'`,`', concat('`',char(10), ',`'))
                                    ,' from ',concat(' ',char(10), ' from'))
                                , ' join ', concat(char(10), ' join '))
                            , ' where ', concat(char(10), ' where '))
                        , ' group by ', concat(char(10), ' group by '))
                    , ' having ', concat(char(10), ' having '))
                , ' order by ', concat(char(10), ' order by '))
            ,' union ', concat(char(10), ' union ', CHAR(10)));
    RETURN clean_view;
END $USD


DELIMITER $USD
DROP FUNCTION IF EXISTS correcciones_31260.VALIDA_NOMBRES$USD

CREATE  FUNCTION correcciones_31260.VALIDA_NOMBRES (OBJECT_NAME varchar(1000))
returns varchar(1000)
NO SQL
BEGIN
    DECLARE BAD_CHARACTERES VARCHAR(1000);
    SELECT regexp_replace(
                REGEXP_replace(OBJECT_NAME, '[a-zA-Z0-9_]','')
            , '[ ]', '(ESP)'
        ) INTO BAD_CHARACTERES;
    RETURN BAD_CHARACTERES;
END $USD

DROP PROCEDURE IF EXISTS correcciones_31260.ANALIZAR_VISTAS$USD

CREATE PROCEDURE correcciones_31260.ANALIZAR_VISTAS(BASE VARCHAR(250))
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE table_name = 'analisis_vistas') THEN
        INSERT INTO correcciones_31260.analisis_vistas (ORDEN,vista,definicion,TIENE_GROUP_BY,TIENE_JOINS,TIENE_UDF,UDFS_DESC,SELECT_SCR)
        WITH VISTAS AS (
            SELECT
                 ROW_NUMBER() OVER (ORDER BY TABLE_SCHEMA, TABLE_NAME) AS ORDEN
                , table_name, view_definition, has_group_by, has_joins_by, has_udf, FUNCTIONS
                , CONCAT('SELECT * FROM `', table_schema, '`.`', table_name, '`;') as select_scr
            FROM (
                SELECT table_schema
                     , table_name
                     , reformat_views(view_definition)                  AS view_definition
                     , MAX(CASE WHEN view_definition LIKE '%group by%' THEN 1 ELSE 0 END) AS has_group_by
                     , MAX(CASE WHEN view_definition LIKE '%join%' THEN 1 ELSE 0 END)     AS has_joins_by
                     , MAX(CASE WHEN rt.routine_name IS NOT NULL THEN 1 ELSE 0 END)       AS has_udf
                     , group_concat(routine_name separator ', ')                     AS functions

                FROM information_schema.views vw
                         LEFT JOIN information_schema.routines rt
                                   ON rt.routine_schema = vw.table_schema
                                       AND vw.view_definition LIKE CONCAT('%', rt.routine_name, '(%)%')
                                       AND rt.routine_type = 'FUNCTION'
                WHERE table_schema = BASE
                group by table_schema
                       , table_name
                       , reformat_views(view_definition)

            ) as x
            )
        SELECT *
        FROM vistas;
    END IF;

END $USD
delimiter ;


delimiter $USD
DROP PROCEDURE IF EXISTS correcciones_31260.ANALIZAR_PROCEDURES$USD
CREATE PROCEDURE correcciones_31260.ANALIZAR_PROCEDURES(BASE VARCHAR(250))
BEGIN
    DECLARE _INT INT;
    DECLARE _DEC DECIMAL(5,2);
    DECLARE _CHAR VARCHAR(20);
    DECLARE _DATE DATE;
    DECLARE _TIME TIME;
    DECLARE _TIMESTAMP TIMESTAMP;

    SET _INT = 8;
    SET _DEC = 8.8;
    SET _CHAR = 'CHAR VAL 8';
    SET _DATE = '2022-08-08';
    SET _TIME = '20:20';
    SET _TIMESTAMP = CURRENT_TIMESTAMP();


        SELECT
            rt.specific_name
            , rt.routine_definition
            -- , GROUP_CONCAT(CONCAT(parameter_name, ':',case when rt.routine_definition like concat('%',pr.parameter_name,'%') then 1 else 0 end) SEPARATOR ', ')
            , concat('call `',base,  '`.`',rt.specific_name, '`(',
                            coalesce(group_concat(CASE WHEN pr.parameter_mode = 'IN' and LOWER(pr.DATA_TYPE) IN ('varchar','char','text','longtext') THEN concat('''', LEFT(_CHAR, pr.CHARACTER_MAXIMUM_LENGTH), '''')
                                WHEN pr.parameter_mode = 'IN' and LOWER(pr.DATA_TYPE) IN ('int', 'bigint','tinyint') THEN _INT
                                when pr.parameter_mode = 'IN' and LOWER(pr.DATA_TYPE) IN ('decimal','float','double') THEN _dec
                                WHEN pr.parameter_mode = 'IN' and LOWER(pr.DATA_TYPE) IN ('datetime','timestamp') THEN concat('''', _timestamp, '''')
                                WHEN pr.parameter_mode = 'IN' and LOWER(pr.DATA_TYPE) IN ('date') THEN concat('''', _date, '''')
                                WHEN pr.parameter_mode = 'OUT' THEN CONCAT('@',pr.parameter_name)
                                else concat('ERR:Undefined ',  pr.parameter_mode ,':', pr.DATA_TYPE)
                            END
                            order by pr.ordinal_position
                            separator ','
                            ),'')
                ,');')
        FROM information_schema.routines RT
            left join information_schema.parameters PR
                on rt.routine_schema = pr.specific_schema
                and rt.routine_name = pr.specific_name
        WHERE rt.ROUTINE_TYPE = 'PROCEDURE'
            AND rt.routine_schema = BASE
        GROUP BY 1,2;

END $USD
DELIMITER ;



DELIMITER $USD
DROP PROCEDURE IF EXISTS correcciones_31260.ANALIZAR_FUNCIONES$USD
CREATE PROCEDURE correcciones_31260.ANALIZAR_FUNCIONES(BASE VARCHAR(250))
BEGIN
    DECLARE _INT INT;
    DECLARE _DEC DECIMAL(5,2);
    DECLARE _CHAR VARCHAR(20);
    DECLARE _DATE DATE;
    DECLARE _TIME TIME;
    DECLARE _TIMESTAMP TIMESTAMP;

    SET _INT = 8;
    SET _DEC = 8.8;
    SET _CHAR = 'CHAR VAL 8';
    SET _DATE = '2022-08-08';
    SET _TIME = '20:20';
    SET _TIMESTAMP = CURRENT_TIMESTAMP();


        SELECT
            rt.specific_name
            , rt.routine_definition
            -- , GROUP_CONCAT(CONCAT(parameter_name, ':',case when rt.routine_definition like concat('%',pr.parameter_name,'%') then 1 else 0 end) SEPARATOR ', ')
            , concat('SELECT `',base,  '`.`',rt.specific_name, '`(',
                            coalesce(group_concat(CASE WHEN pr.parameter_mode = 'IN' and LOWER(pr.DATA_TYPE) IN ('varchar','char','text','longtext','tinytext') THEN concat('''', LEFT(_CHAR, pr.CHARACTER_MAXIMUM_LENGTH), '''')
                                WHEN pr.parameter_mode = 'IN' and LOWER(pr.DATA_TYPE) IN ('int', 'bigint','tinyint') THEN _INT
                                when pr.parameter_mode = 'IN' and LOWER(pr.DATA_TYPE) IN ('decimal','float','double') THEN _dec
                                WHEN pr.parameter_mode = 'IN' and LOWER(pr.DATA_TYPE) IN ('datetime','timestamp') THEN concat('''', _timestamp, '''')
                                WHEN pr.parameter_mode = 'IN' and LOWER(pr.DATA_TYPE) IN ('date') THEN concat('''', _date, '''')
                                WHEN pr.parameter_mode = 'OUT' THEN CONCAT('@',pr.parameter_name)
                                else concat('ERR:Undefined ',  pr.parameter_mode ,':', pr.DATA_TYPE)
                            END
                            order by pr.ordinal_position
                            separator ','
                            ),'')

                ,');')
        FROM information_schema.routines RT
            left join information_schema.parameters PR
                on rt.routine_schema = pr.specific_schema
                and rt.routine_name = pr.specific_name
        WHERE rt.ROUTINE_TYPE = 'FUNCTION'
            AND rt.routine_schema = BASE
        GROUP BY 1,2;

END $USD
DELIMITER ;


DELIMITER $USD
DROP PROCEDURE IF EXISTS correcciones_31260.ANALIZAR_TRIGGERS$USD
CREATE PROCEDURE correcciones_31260.ANALIZAR_TRIGGERS(BASE VARCHAR(250))
BEGIN
    SELECT
      EVENT_OBJECT_TABLE, CONCAT(TG.ACTION_TIMING, ' ', event_manipulation) AS EVENT_TYPE, action_statement
    FROM information_schema.triggers TG
    WHERE TG.trigger_schema = BASE
    ORDER BY event_object_table, event_manipulation, action_timing, action_order;
END $USD
DELIMITER ;
-- a los triggers, agregar los nombres


call ANALIZAR_BASE('aerolineas2');






