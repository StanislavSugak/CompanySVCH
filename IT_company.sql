PGDMP                      |         
   IT_company    17.0    17.0 ^    g           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            h           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            i           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            j           1262    17970 
   IT_company    DATABASE     �   CREATE DATABASE "IT_company" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';
    DROP DATABASE "IT_company";
                     postgres    false                       1255    18566    get_user_details(integer)    FUNCTION     �  CREATE FUNCTION public.get_user_details(p_user_id integer) RETURNS TABLE(user_id integer, email character varying, direction_name character varying, stacks_languages jsonb, stacks_libraries_technologies jsonb, stacks_others jsonb, stacks_learning_in_progress jsonb, stacks_learning_completed jsonb, name character varying, surname character varying, patronymic character varying, birthday date, telephone character varying, address character varying, image character varying, vk_name character varying, instagram_name character varying, telegram_name character varying, linkedin_name character varying, date_hire date)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id AS user_id,
        u.email ,
        d.direction AS direction_name,     
        
        -- Stacks: Languages
        (
            SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 'grade', us.grade, 'type', s.type, 'is_mentor', us.is_mentor))
            FROM user_stacks us 
            JOIN stacks s ON us.id_stack = s.id 
            WHERE us.id_user = u.id AND s.type = 'Language'
        ) AS stacks_languages,

        -- Stacks: Libraries and Technologies
        (
            SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 'grade', us.grade, 'type', s.type, 'is_mentor', us.is_mentor))
            FROM user_stacks us 
            JOIN stacks s ON us.id_stack = s.id 
            WHERE us.id_user = u.id AND s.type IN ('Library', 'Framework')
        ) AS stacks_libraries_technologies,

        -- Stacks: Others
        (
            SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 'grade', us.grade, 'type', s.type, 'is_mentor', us.is_mentor))
            FROM user_stacks us 
            JOIN stacks s ON us.id_stack = s.id 
            WHERE us.id_user = u.id AND s.type NOT IN ('Language', 'Library', 'Framework')
        ) AS stacks_others,

        -- Stacks: Learning In Progress
        (
            SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 
                'date_enter', to_char(ul.date_enter, 'DD.MM.YYYY')::VARCHAR, 
                'date_end', to_char(ul.date_end, 'DD.MM.YYYY')::VARCHAR, 
                'grade', ul.grade, 
                'direction', d.direction,
                'id_learn', ul.id))
            FROM user_learns ul 
            JOIN stacks s ON ul.id_stack = s.id 
            JOIN directions d ON d.id = s.id_direction
            WHERE ul.id_user = u.id AND ul.date_end IS NULL
        ) AS stacks_learning_in_progress,

        -- Stacks: Learning Completed
        (
            SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 
                'date_enter', to_char(ul.date_enter, 'DD.MM.YYYY')::VARCHAR, 
                'date_end', to_char(ul.date_end, 'DD.MM.YYYY')::VARCHAR, 
                'grade', ul.grade, 
                'direction', d.direction,
                'id_learn', ul.id))
            FROM user_learns ul 
            JOIN stacks s ON ul.id_stack = s.id 
            JOIN directions d ON d.id = s.id_direction
            WHERE ul.id_user = u.id AND ul.date_end IS NOT NULL
        ) AS stacks_learning_completed,

        up.name,
        up.surname,
        up.patronymic,
        to_char(up.birthday, 'DD.MM.YYYY')::VARCHAR AS birthday,
        up.telephone,
        up.address,
        up.image,
        up.vk_name,
        up.instagram_name,
        up.telegram_name,
        up.linkedin_name,
        to_char(up.date_hire, 'DD.MM.YYYY')::VARCHAR AS date_hire
    FROM 
        users u
    LEFT JOIN 
        directions d ON u.id_direction = d.id
    LEFT JOIN 
        user_personals up ON u.id = up.id_user
    WHERE 
        u.id = p_user_id;
END;
$$;
 :   DROP FUNCTION public.get_user_details(p_user_id integer);
       public               postgres    false            �            1255    18221    getalldirections()    FUNCTION     �   CREATE FUNCTION public.getalldirections() RETURNS TABLE(id integer, direction character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM directions;
END;
$$;
 )   DROP FUNCTION public.getalldirections();
       public               postgres    false            �            1255    18541    getdirection()    FUNCTION     �   CREATE FUNCTION public.getdirection() RETURNS TABLE(id integer, direction character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM directions;
END;
$$;
 %   DROP FUNCTION public.getdirection();
       public               postgres    false            �            1255    18209 "   getprojectsdatabyemployee(integer)    FUNCTION     �
  CREATE FUNCTION public.getprojectsdatabyemployee(p_user_id integer) RETURNS TABLE(project_id integer, project_name character varying, project_description character varying, project_date_start timestamp with time zone, project_date_delay timestamp with time zone, project_date_end timestamp with time zone, project_bus_factor integer, project_id_teamlead integer, project_teamlead_name character varying, project_teamlead_surname character varying, users jsonb, stacks jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id AS project_id,
        p.name AS project_name,
        p.description AS project_description,  
        p.date_start AS project_date_start,
        p.date_delay AS project_date_delay,
        p.date_end AS project_date_end,
        p.bus_factor AS project_bus_factor,
        p.id_teamlead AS project_id_teamlead,
        up1.name AS project_teamlead_name,
        up1.surname AS project_teamlead_surname,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'user_id', up.id_user,
                    'user_name', up.name,
                    'user_surname', up.surname,
                    'stacks', (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id_stack', us1.id_stack,
                                'grade', us1.grade,
                                'is_mentor', us1.is_mentor
                            )
                        )
                        FROM user_stacks us1
                        WHERE us1.id_user = up.id_user
                    )
                )
            )
 			FROM project_users pu
			JOIN user_stacks us1 ON pu.id_user_stack = us1.id
            JOIN user_personals up ON up.id_user = us1.id_user
            WHERE pu.id_project = p.id
        ) AS users,
        (
            SELECT jsonb_agg(jsonb_build_object(
                'stack_id', s.id, 
                'stack_name', s.name, 
                'required_count', ps.count_required,
                'direction_name', d.direction
            )) 
            FROM project_stacks ps
            JOIN stacks s ON ps.id_stack = s.id
            JOIN directions d ON s.id_direction = d.id
            WHERE ps.id_project = p.id
            GROUP BY ps.id_project
        ) AS stacks
    FROM
        projects p
    LEFT JOIN 
        user_personals up1 ON p.id_teamlead = up1.id_user
    WHERE
        EXISTS (
            SELECT 1
            FROM project_users pu2
            WHERE pu2.id_project = p.id AND pu2.id_user_stack IN (
                SELECT us3.id
                FROM user_stacks us3
                WHERE us3.id_user = p_user_id
            )
        );
END;
$$;
 C   DROP FUNCTION public.getprojectsdatabyemployee(p_user_id integer);
       public               postgres    false            �            1255    18207 "   getprojectsdatabyteamlead(integer)    FUNCTION     �	  CREATE FUNCTION public.getprojectsdatabyteamlead(p_teamlead_id integer) RETURNS TABLE(project_id integer, project_name character varying, project_description character varying, project_date_start timestamp with time zone, project_date_delay timestamp with time zone, project_date_end timestamp with time zone, project_bus_factor integer, project_id_teamlead integer, project_teamlead_name character varying, project_teamlead_surname character varying, users jsonb, stacks jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id AS project_id,
        p.name AS project_name,
        p.description AS project_description,  
        p.date_start AS project_date_start,
        p.date_delay AS project_date_delay,
        p.date_end AS project_date_end,
        p.bus_factor AS project_bus_factor,
        p.id_teamlead AS project_id_teamlead,
        up1.name AS project_teamlead_name,
        up1.surname AS project_teamlead_surname,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'user_id', up.id_user,
                    'user_name', up.name,
                    'user_surname', up.surname,
                    'stacks', (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id_stack', us1.id_stack,
                                'grade', us1.grade,
                                'is_mentor', us1.is_mentor
                            )
                        )
                        FROM user_stacks us1
                        WHERE us1.id_user = up.id_user
                    )
                )
            )
            FROM project_users pu
            JOIN user_stacks us1 ON pu.id_user_stack = us1.id
            JOIN user_personals up ON up.id_user = us1.id_user
            WHERE pu.id_project = p.id
        ) AS users,
        (
            SELECT jsonb_agg(jsonb_build_object(
                'stack_id', s.id, 
                'stack_name', s.name, 
                'required_count', ps.count_required,
                'direction_name', d.direction
            )) 
            FROM project_stacks ps
            JOIN stacks s ON ps.id_stack = s.id
            JOIN directions d ON s.id_direction = d.id
            WHERE ps.id_project = p.id
            GROUP BY ps.id_project
        ) AS stacks
    FROM
        projects p
    LEFT JOIN 
        user_personals up1 ON p.id_teamlead = up1.id_user
    WHERE
        p.id_teamlead = p_teamlead_id;
END;
$$;
 G   DROP FUNCTION public.getprojectsdatabyteamlead(p_teamlead_id integer);
       public               postgres    false                       1255    18557 ;   getprojectsdatabyteamleadfilter(integer, character varying)    FUNCTION     �  CREATE FUNCTION public.getprojectsdatabyteamleadfilter(p_teamlead_id integer, p_status character varying) RETURNS TABLE(project_id integer, project_name character varying, project_description character varying, project_date_start timestamp with time zone, project_date_delay timestamp with time zone, project_date_end timestamp with time zone, project_bus_factor integer, project_id_teamlead integer, project_teamlead_name character varying, project_teamlead_surname character varying, users jsonb, stacks jsonb, main_user jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id AS project_id,
        p.name AS project_name,
        p.description AS project_description,  
        p.date_start AS project_date_start,
        p.date_delay AS project_date_delay,
        p.date_end AS project_date_end,
        p.bus_factor AS project_bus_factor,
        p.id_teamlead AS project_id_teamlead,
        up1.name AS project_teamlead_name,
        up1.surname AS project_teamlead_surname,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'user_id', up.id_user,
                    'user_name', up.name,
                    'user_surname', up.surname,
                    'stacks', (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id_stack', us1.id_stack,
                                'grade', us1.grade,
                                'is_mentor', us1.is_mentor
                            )
                        )
                        FROM user_stacks us1
                        WHERE us1.id_user = up.id_user
                    )
                )
            )
            FROM project_users pu
            JOIN user_stacks us1 ON pu.id_user_stack = us1.id
            JOIN user_personals up ON up.id_user = us1.id_user
            WHERE pu.id_project = p.id
        ) AS users,
        (
            SELECT jsonb_agg(jsonb_build_object(
                'stack_id', s.id, 
                'stack_name', s.name, 
                'required_count', ps.count_required,
                'direction_name', d.direction
            )) 
            FROM project_stacks ps
            JOIN stacks s ON ps.id_stack = s.id
            JOIN directions d ON s.id_direction = d.id
            WHERE ps.id_project = p.id
            GROUP BY ps.id_project
        ) AS stacks,
        (
            SELECT jsonb_agg(jsonb_build_object(
                'user_id', us.id_user,  -- Исправлено на us.id_user
                'stack_id', us.id_stack
            ))
            FROM project_users pu
            JOIN user_stacks us ON pu.id_user_stack = us.id
            WHERE pu.id_project = p.id
        ) AS main_user
    FROM
        projects p
    LEFT JOIN 
        user_personals up1 ON p.id_teamlead = up1.id_user
    WHERE
        p.id_teamlead = p_teamlead_id
        AND
        (
            (p_status = 'progress' AND p.date_delay IS NOT NULL AND p.date_end IS NULL)
            OR
            (p_status = 'completed' AND p.date_end IS NOT NULL)
            OR
            (p_status IS NULL AND p.date_delay IS NULL AND p.date_end IS NULL) -- Для проектов, которые не завершены и не в процессе
        );
END;
$$;
 i   DROP FUNCTION public.getprojectsdatabyteamleadfilter(p_teamlead_id integer, p_status character varying);
       public               postgres    false                        1255    18216 7   getprojectsdatabyuserfilter(integer, character varying)    FUNCTION     R  CREATE FUNCTION public.getprojectsdatabyuserfilter(p_user_id integer, p_status character varying) RETURNS TABLE(project_id integer, project_name character varying, project_description character varying, project_date_start timestamp with time zone, project_date_delay timestamp with time zone, project_date_end timestamp with time zone, project_bus_factor integer, project_id_teamlead integer, project_teamlead_name character varying, project_teamlead_surname character varying, users jsonb, stacks jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id AS project_id,
        p.name AS project_name,
        p.description AS project_description,  
        p.date_start AS project_date_start,
        p.date_delay AS project_date_delay,
        p.date_end AS project_date_end,
        p.bus_factor AS project_bus_factor,
        p.id_teamlead AS project_id_teamlead,
        up1.name AS project_teamlead_name,
        up1.surname AS project_teamlead_surname,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'user_id', up.id_user,
                    'user_name', up.name,
                    'user_surname', up.surname,
					'user_direction', d4.direction,
                    'stacks', (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id_stack', us1.id_stack,
                                'grade', us1.grade,
                                'is_mentor', us1.is_mentor
                            )
                        )
                        FROM user_stacks us1
                        WHERE us1.id_user = up.id_user
                    )
                )
            )
            FROM project_users pu
            JOIN user_stacks us1 ON pu.id_user_stack = us1.id
            JOIN user_personals up ON up.id_user = us1.id_user
			JOIN users u4 ON u4.id = up.id_user
			JOIN directions d4 ON d4.id = u4.id_direction
            WHERE pu.id_project = p.id
        ) AS users,
        (
            SELECT jsonb_agg(jsonb_build_object(
                'stack_id', s.id, 
                'stack_name', s.name, 
                'required_count', ps.count_required,
                'direction_name', d.direction
            )) 
            FROM project_stacks ps
            JOIN stacks s ON ps.id_stack = s.id
            JOIN directions d ON s.id_direction = d.id
            WHERE ps.id_project = p.id
            GROUP BY ps.id_project
        ) AS stacks
    FROM
        projects p
    LEFT JOIN 
        user_personals up1 ON p.id_teamlead = up1.id_user
    WHERE
        (
            -- Условие для проектов по конкретному пользователю
            EXISTS (
                SELECT 1
                FROM project_users pu2
                WHERE pu2.id_project = p.id AND pu2.id_user_stack IN (
                    SELECT us3.id
                    FROM user_stacks us3
                    WHERE us3.id_user = p_user_id
                )
            )
            OR
            -- Условие для всех проектов без фильтрации по пользователю
            (p.date_delay IS NULL AND p.date_end IS NULL)
        )
        AND 
        (
            (p_status = 'progress' AND p.date_delay IS NOT NULL AND p.date_end IS NULL)
            OR
            (p_status = 'completed' AND p.date_end IS NOT NULL)
            OR
            (p_status IS NULL AND p.date_delay IS NULL AND p.date_end IS NULL) -- Для проектов, которые не завершены и не в процессе
        );
END;
$$;
 a   DROP FUNCTION public.getprojectsdatabyuserfilter(p_user_id integer, p_status character varying);
       public               postgres    false            �            1255    18211 :   getprojectsdatabyuserfilternew(integer, character varying)    FUNCTION       CREATE FUNCTION public.getprojectsdatabyuserfilternew(p_user_id integer, p_status character varying) RETURNS TABLE(project_id integer, project_name character varying, project_description character varying, project_date_start timestamp with time zone, project_date_delay timestamp with time zone, project_date_end timestamp with time zone, project_bus_factor integer, project_id_teamlead integer, project_teamlead_name character varying, project_teamlead_surname character varying, users jsonb, stacks jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id AS project_id,
        p.name AS project_name,
        p.description AS project_description,  
        p.date_start AS project_date_start,
        p.date_delay AS project_date_delay,
        p.date_end AS project_date_end,
        p.bus_factor AS project_bus_factor,
        p.id_teamlead AS project_id_teamlead,
        up1.name AS project_teamlead_name,
        up1.surname AS project_teamlead_surname,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'user_id', up.id_user,
                    'user_name', up.name,
                    'user_surname', up.surname,
                    'stacks', (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id_stack', us1.id_stack,
                                'grade', us1.grade,
                                'is_mentor', us1.is_mentor
                            )
                        )
                        FROM user_stacks us1
                        WHERE us1.id_user = up.id_user
                    )
                )
            )
            FROM project_users pu
            JOIN user_stacks us1 ON pu.id_user_stack = us1.id
            JOIN user_personals up ON up.id_user = us1.id_user
            WHERE pu.id_project = p.id
        ) AS users,
        (
            SELECT jsonb_agg(jsonb_build_object(
                'stack_id', s.id, 
                'stack_name', s.name, 
                'required_count', ps.count_required,
                'direction_name', d.direction
            )) 
            FROM project_stacks ps
            JOIN stacks s ON ps.id_stack = s.id
            JOIN directions d ON s.id_direction = d.id
            WHERE ps.id_project = p.id
            GROUP BY ps.id_project
        ) AS stacks
    FROM
        projects p
    LEFT JOIN 
        user_personals up1 ON p.id_teamlead = up1.id_user
    WHERE
        (
            -- Условие для пользователя и статуса
            EXISTS (
                SELECT 1
                FROM project_users pu2
                WHERE pu2.id_project = p.id AND pu2.id_user_stack IN (
                    SELECT us3.id
                    FROM user_stacks us3
                    WHERE us3.id_user = p_user_id
                )
            )
            AND 
            (
                (p_status = 'progress' AND (p.date_delay IS NOT NULL) AND p.date_end IS NULL)
                OR
                (p_status = 'completed' AND p.date_end IS NOT NULL)
            )
        )
        OR
        (
            -- Условие для всех проектов, если date_delay и date_end равны NULL
            p.date_delay IS NULL AND p.date_end IS NULL
        );
END;
$$;
 d   DROP FUNCTION public.getprojectsdatabyuserfilternew(p_user_id integer, p_status character varying);
       public               postgres    false            �            1255    18206    getprojectsdatas()    FUNCTION     �	  CREATE FUNCTION public.getprojectsdatas() RETURNS TABLE(project_id integer, project_name character varying, project_description character varying, project_date_start timestamp with time zone, project_date_delay timestamp with time zone, project_date_end timestamp with time zone, project_bus_factor integer, project_id_teamlead integer, project_teamlead_name character varying, project_teamlead_surname character varying, users jsonb, stacks jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id AS project_id,
        p.name AS project_name,
        p.description AS project_description,  
        p.date_start AS project_date_start,
        p.date_delay AS project_date_delay,
        p.date_end AS project_date_end,
        p.bus_factor AS project_bus_factor,
        p.id_teamlead AS project_id_teamlead,
        up1.name AS project_teamlead_name,
        up1.surname AS project_teamlead_surname,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'user_id', up.id_user,
                    'user_name', up.name,
                    'user_surname', up.surname,
                    'stacks', (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id_stack', us1.id_stack,
                                'grade', us1.grade,
                                'is_mentor', us1.is_mentor
                            )
                        )
                        FROM user_stacks us1
                        WHERE us1.id_user = up.id_user
                    )
                )
            )
            FROM project_users pu
            JOIN user_stacks us1 ON pu.id_user_stack = us1.id
            JOIN user_personals up ON up.id_user = us1.id_user
            WHERE pu.id_project = p.id
        ) AS users,
        (
            SELECT jsonb_agg(jsonb_build_object(
                'stack_id', s.id, 
                'stack_name', s.name, 
                'required_count', ps.count_required,
                'direction_name', d.direction
            )) 
            FROM project_stacks ps
            JOIN stacks s ON ps.id_stack = s.id
            JOIN directions d ON s.id_direction = d.id
            WHERE ps.id_project = p.id
            GROUP BY ps.id_project
        ) AS stacks
    FROM
        projects p
    LEFT JOIN 
        user_personals up1 ON p.id_teamlead = up1.id_user;
END;
$$;
 )   DROP FUNCTION public.getprojectsdatas();
       public               postgres    false            �            1255    18196    getprojectstacks()    FUNCTION     P  CREATE FUNCTION public.getprojectstacks() RETURNS TABLE(project_id integer, stacks jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ps.id_project AS project_id,
        jsonb_agg(jsonb_build_object(
            'stack_id', s.id, 
            'stack_name', s.name, 
            'required_count', ps.count_required,
            'direction_name', d.direction
        )) AS stacks
    FROM
        project_stacks ps
    JOIN
        stacks s ON ps.id_stack = s.id
    JOIN
        directions d ON s.id_direction = d.id
    GROUP BY
        ps.id_project;
END;
$$;
 )   DROP FUNCTION public.getprojectstacks();
       public               postgres    false            �            1255    18544 
   getstack()    FUNCTION     �  CREATE FUNCTION public.getstack() RETURNS TABLE(direction_id integer, direction_name character varying, stacks jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY 
    SELECT d.id AS direction_id, 
           d.direction AS direction_name,
           COALESCE(jsonb_agg(jsonb_build_object('stack_id', s.id, 'stack_name', s.name)) FILTER (WHERE s.id IS NOT NULL), '[]'::jsonb) AS stacks
    FROM directions d
    LEFT JOIN stacks s ON d.id = s.id_direction
    GROUP BY d.id, d.direction;
END;
$$;
 !   DROP FUNCTION public.getstack();
       public               postgres    false            �            1255    18222    getstacksbydirection(integer)    FUNCTION     T  CREATE FUNCTION public.getstacksbydirection(direction_id integer) RETURNS TABLE(id_stack integer, id_direction integer, name character varying, type character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.id_direction, s.name, s.type
    FROM stacks s
	
    WHERE s.id_direction = direction_id;
END;
$$;
 A   DROP FUNCTION public.getstacksbydirection(direction_id integer);
       public               postgres    false                       1255    18568    getuser(integer)    FUNCTION     x  CREATE FUNCTION public.getuser(p_user_id integer) RETURNS TABLE(user_id integer, email character varying, direction_name character varying, stacks_languages jsonb, stacks_libraries_technologies jsonb, stacks_others jsonb, stacks_learning_in_progress jsonb, stacks_learning_completed jsonb, name character varying, surname character varying, patronymic character varying, birthday date, telephone character varying, address character varying, image character varying, vk_name character varying, instagram_name character varying, telegram_name character varying, linkedin_name character varying, date_hire date)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id AS user_id,
        u.email,
        d.direction AS direction_name,
        
        -- Стacks: Languages
        (
            SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 'grade', us.grade, 'type', s.type))
            FROM user_stacks us 
            JOIN stacks s ON us.id_stack = s.id 
            WHERE us.id_user = u.id AND s.type = 'Language'  -- Условие для языков
        ) AS stacks_languages,

        -- Stacks: Libraries and Technologies
        (
            SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 'grade', us.grade, 'type', s.type))
            FROM user_stacks us 
            JOIN stacks s ON us.id_stack = s.id 
            WHERE us.id_user = u.id AND s.type IN ('Library', 'Framework')  -- Условие для библиотек и технологий
        ) AS stacks_libraries_technologies,

        -- Stacks: Others
        (
            SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 'grade', us.grade, 'type', s.type))
            FROM user_stacks us 
            JOIN stacks s ON us.id_stack = s.id 
            WHERE us.id_user = u.id AND s.type NOT IN ('Language', 'Library', 'Framework')  -- Условие для остальных
        ) AS stacks_others,

        -- Стacks: Learning In Progress
        (
            SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 
                'date_enter', to_char(ul.date_enter, 'DD.MM.YYYY')::VARCHAR, 
                'date_end', to_char(ul.date_end, 'DD.MM.YYYY')::VARCHAR, 
                'grade', ul.grade, 
                'direction', d.direction,
                'id_learn', ul.id))
            FROM user_learns ul 
            JOIN stacks s ON ul.id_stack = s.id 
            JOIN directions d ON d.id = s.id_direction
            WHERE ul.id_user = u.id AND ul.date_end IS NULL
        ) AS stacks_learning_in_progress,

        -- Стacks: Learning Completed
        (
            SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 
                'date_enter', to_char(ul.date_enter, 'DD.MM.YYYY')::VARCHAR, 
                'date_end', to_char(ul.date_end, 'DD.MM.YYYY')::VARCHAR, 
                'grade', ul.grade, 
                'direction', d.direction,
                'id_learn', ul.id))
            FROM user_learns ul 
            JOIN stacks s ON ul.id_stack = s.id 
            JOIN directions d ON d.id = s.id_direction
            WHERE ul.id_user = u.id AND ul.date_end IS NOT NULL
        ) AS stacks_learning_completed,

        up.name,
        up.surname,
        up.patronymic,
        up.birthday::DATE,
        up.telephone,
        up.address,
        up.image,
        up.vk_name,
        up.instagram_name,
        up.telegram_name,
        up.linkedin_name,
        up.date_hire::DATE
    FROM 
        users u
    LEFT JOIN 
        directions d ON u.id_direction = d.id
    LEFT JOIN 
        user_personals up ON u.id = up.id_user
    WHERE 
        u.id = p_user_id;
END;
$$;
 1   DROP FUNCTION public.getuser(p_user_id integer);
       public               postgres    false            �            1255    18510    getusers(character varying)    FUNCTION     �  CREATE FUNCTION public.getusers(sortby character varying) RETURNS TABLE(id integer, gmail character varying, role character varying, direction character varying, name character varying, surname character varying, date_hire text, image character varying, telegram character varying, vk character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    EXECUTE FORMAT(
        'SELECT 
            u.id,
            u.email AS gmail,
			u.role AS role,
            d.direction AS direction,
            up.name AS name,
            up.surname AS surname,
            TO_CHAR(up.date_hire, ''YYYY-MM-DD'') AS date_hire,
            up.image AS image,
            up.telegram_name AS telegram,
            up.vk_name AS vk
        FROM 
            Users u
        JOIN 
            Directions d ON u.id_direction = d.id
        JOIN 
            User_Personals up ON u.id = up.id_user
        ORDER BY 
            CASE 
                WHEN %L = ''name'' THEN up.name
                WHEN %L = ''date_hire'' THEN TO_CHAR(up.date_hire, ''YYYY-MM-DD'') 
                WHEN %L = ''direction'' THEN d.direction
                ELSE up.name  -- Значение по умолчанию
            END', sortBy, sortBy, sortBy, sortBy
    );
END;
$$;
 9   DROP FUNCTION public.getusers(sortby character varying);
       public               postgres    false            �            1259    17972 
   directions    TABLE     a   CREATE TABLE public.directions (
    id integer NOT NULL,
    direction character varying(30)
);
    DROP TABLE public.directions;
       public         heap r       postgres    false            �            1259    17971    directions_id_seq    SEQUENCE     �   CREATE SEQUENCE public.directions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.directions_id_seq;
       public               postgres    false    218            k           0    0    directions_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.directions_id_seq OWNED BY public.directions.id;
          public               postgres    false    217            �            1259    18040    project_stacks    TABLE     �   CREATE TABLE public.project_stacks (
    id_project integer NOT NULL,
    id_stack integer NOT NULL,
    count_required integer
);
 "   DROP TABLE public.project_stacks;
       public         heap r       postgres    false            �            1259    18072    project_users    TABLE     �   CREATE TABLE public.project_users (
    id_project integer NOT NULL,
    id_user_stack integer NOT NULL,
    raiting integer
);
 !   DROP TABLE public.project_users;
       public         heap r       postgres    false            �            1259    18016    projects    TABLE     6  CREATE TABLE public.projects (
    id integer NOT NULL,
    name character varying(25),
    description character varying(255),
    date_start timestamp with time zone,
    date_delay timestamp with time zone,
    date_end timestamp with time zone,
    bus_factor integer DEFAULT 0,
    id_teamlead integer
);
    DROP TABLE public.projects;
       public         heap r       postgres    false            �            1259    18015    projects_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.projects_id_seq;
       public               postgres    false    224            l           0    0    projects_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;
          public               postgres    false    223            �            1259    18005    refresh_tokens    TABLE     o   CREATE TABLE public.refresh_tokens (
    id_user integer NOT NULL,
    refresh_token character varying(255)
);
 "   DROP TABLE public.refresh_tokens;
       public         heap r       postgres    false            �            1259    18029    stacks    TABLE     �   CREATE TABLE public.stacks (
    id integer NOT NULL,
    name character varying(25),
    type character varying(15),
    id_direction integer
);
    DROP TABLE public.stacks;
       public         heap r       postgres    false            �            1259    18028    stacks_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stacks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.stacks_id_seq;
       public               postgres    false    226            m           0    0    stacks_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.stacks_id_seq OWNED BY public.stacks.id;
          public               postgres    false    225            �            1259    18105    user_learn_histories    TABLE     �   CREATE TABLE public.user_learn_histories (
    id integer NOT NULL,
    id_learn integer,
    date_learn timestamp with time zone,
    type character varying(30),
    grade integer
);
 (   DROP TABLE public.user_learn_histories;
       public         heap r       postgres    false            �            1259    18104    user_learn_histories_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_learn_histories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.user_learn_histories_id_seq;
       public               postgres    false    234            n           0    0    user_learn_histories_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.user_learn_histories_id_seq OWNED BY public.user_learn_histories.id;
          public               postgres    false    233            �            1259    18088    user_learns    TABLE     �   CREATE TABLE public.user_learns (
    id integer NOT NULL,
    id_user integer,
    id_stack integer,
    date_enter timestamp with time zone,
    date_end timestamp with time zone,
    grade integer
);
    DROP TABLE public.user_learns;
       public         heap r       postgres    false            �            1259    18087    user_learns_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_learns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.user_learns_id_seq;
       public               postgres    false    232            o           0    0    user_learns_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.user_learns_id_seq OWNED BY public.user_learns.id;
          public               postgres    false    231            �            1259    17993    user_personals    TABLE       CREATE TABLE public.user_personals (
    id_user integer NOT NULL,
    name character varying(20),
    surname character varying(20),
    patronymic character varying(20),
    birthday timestamp with time zone,
    telephone character varying(17),
    address character varying(255),
    image character varying(255),
    vk_name character varying(35),
    instagram_name character varying(35),
    telegram_name character varying(35),
    linkedin_name character varying(35),
    date_hire timestamp with time zone
);
 "   DROP TABLE public.user_personals;
       public         heap r       postgres    false            �            1259    18056    user_stacks    TABLE     �   CREATE TABLE public.user_stacks (
    id integer NOT NULL,
    id_user integer,
    id_stack integer,
    grade integer,
    is_mentor boolean
);
    DROP TABLE public.user_stacks;
       public         heap r       postgres    false            �            1259    18055    user_stacks_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_stacks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.user_stacks_id_seq;
       public               postgres    false    229            p           0    0    user_stacks_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.user_stacks_id_seq OWNED BY public.user_stacks.id;
          public               postgres    false    228            �            1259    17979    users    TABLE     �   CREATE TABLE public.users (
    id integer NOT NULL,
    role character varying(20) DEFAULT 'employee'::character varying,
    email character varying(45),
    password character varying(255),
    id_direction integer
);
    DROP TABLE public.users;
       public         heap r       postgres    false            �            1259    17978    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public               postgres    false    220            q           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public               postgres    false    219            �           2604    17975    directions id    DEFAULT     n   ALTER TABLE ONLY public.directions ALTER COLUMN id SET DEFAULT nextval('public.directions_id_seq'::regclass);
 <   ALTER TABLE public.directions ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    218    217    218            �           2604    18019    projects id    DEFAULT     j   ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);
 :   ALTER TABLE public.projects ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    224    223    224            �           2604    18032 	   stacks id    DEFAULT     f   ALTER TABLE ONLY public.stacks ALTER COLUMN id SET DEFAULT nextval('public.stacks_id_seq'::regclass);
 8   ALTER TABLE public.stacks ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    225    226    226            �           2604    18108    user_learn_histories id    DEFAULT     �   ALTER TABLE ONLY public.user_learn_histories ALTER COLUMN id SET DEFAULT nextval('public.user_learn_histories_id_seq'::regclass);
 F   ALTER TABLE public.user_learn_histories ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    233    234    234            �           2604    18091    user_learns id    DEFAULT     p   ALTER TABLE ONLY public.user_learns ALTER COLUMN id SET DEFAULT nextval('public.user_learns_id_seq'::regclass);
 =   ALTER TABLE public.user_learns ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    232    231    232            �           2604    18059    user_stacks id    DEFAULT     p   ALTER TABLE ONLY public.user_stacks ALTER COLUMN id SET DEFAULT nextval('public.user_stacks_id_seq'::regclass);
 =   ALTER TABLE public.user_stacks ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    228    229    229            �           2604    17982    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    219    220    220            T          0    17972 
   directions 
   TABLE DATA           3   COPY public.directions (id, direction) FROM stdin;
    public               postgres    false    218   D�       ]          0    18040    project_stacks 
   TABLE DATA           N   COPY public.project_stacks (id_project, id_stack, count_required) FROM stdin;
    public               postgres    false    227   ��       `          0    18072    project_users 
   TABLE DATA           K   COPY public.project_users (id_project, id_user_stack, raiting) FROM stdin;
    public               postgres    false    230   ��       Z          0    18016    projects 
   TABLE DATA           t   COPY public.projects (id, name, description, date_start, date_delay, date_end, bus_factor, id_teamlead) FROM stdin;
    public               postgres    false    224   ��       X          0    18005    refresh_tokens 
   TABLE DATA           @   COPY public.refresh_tokens (id_user, refresh_token) FROM stdin;
    public               postgres    false    222   ��       \          0    18029    stacks 
   TABLE DATA           >   COPY public.stacks (id, name, type, id_direction) FROM stdin;
    public               postgres    false    226   ��       d          0    18105    user_learn_histories 
   TABLE DATA           U   COPY public.user_learn_histories (id, id_learn, date_learn, type, grade) FROM stdin;
    public               postgres    false    234   1�       b          0    18088    user_learns 
   TABLE DATA           Y   COPY public.user_learns (id, id_user, id_stack, date_enter, date_end, grade) FROM stdin;
    public               postgres    false    232   N�       W          0    17993    user_personals 
   TABLE DATA           �   COPY public.user_personals (id_user, name, surname, patronymic, birthday, telephone, address, image, vk_name, instagram_name, telegram_name, linkedin_name, date_hire) FROM stdin;
    public               postgres    false    221   �       _          0    18056    user_stacks 
   TABLE DATA           N   COPY public.user_stacks (id, id_user, id_stack, grade, is_mentor) FROM stdin;
    public               postgres    false    229   �       V          0    17979    users 
   TABLE DATA           H   COPY public.users (id, role, email, password, id_direction) FROM stdin;
    public               postgres    false    220   ��       r           0    0    directions_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.directions_id_seq', 9, true);
          public               postgres    false    217            s           0    0    projects_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.projects_id_seq', 24, true);
          public               postgres    false    223            t           0    0    stacks_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.stacks_id_seq', 71, true);
          public               postgres    false    225            u           0    0    user_learn_histories_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.user_learn_histories_id_seq', 1, false);
          public               postgres    false    233            v           0    0    user_learns_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.user_learns_id_seq', 10, true);
          public               postgres    false    231            w           0    0    user_stacks_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.user_stacks_id_seq', 87, true);
          public               postgres    false    228            x           0    0    users_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.users_id_seq', 34, true);
          public               postgres    false    219            �           2606    17977    directions directions_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.directions
    ADD CONSTRAINT directions_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.directions DROP CONSTRAINT directions_pkey;
       public                 postgres    false    218            �           2606    18044 "   project_stacks project_stacks_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.project_stacks
    ADD CONSTRAINT project_stacks_pkey PRIMARY KEY (id_project, id_stack);
 L   ALTER TABLE ONLY public.project_stacks DROP CONSTRAINT project_stacks_pkey;
       public                 postgres    false    227    227            �           2606    18076     project_users project_users_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_pkey PRIMARY KEY (id_project, id_user_stack);
 J   ALTER TABLE ONLY public.project_users DROP CONSTRAINT project_users_pkey;
       public                 postgres    false    230    230            �           2606    18022    projects projects_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.projects DROP CONSTRAINT projects_pkey;
       public                 postgres    false    224            �           2606    18009 "   refresh_tokens refresh_tokens_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id_user);
 L   ALTER TABLE ONLY public.refresh_tokens DROP CONSTRAINT refresh_tokens_pkey;
       public                 postgres    false    222            �           2606    18034    stacks stacks_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.stacks
    ADD CONSTRAINT stacks_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.stacks DROP CONSTRAINT stacks_pkey;
       public                 postgres    false    226            �           2606    18110 .   user_learn_histories user_learn_histories_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.user_learn_histories
    ADD CONSTRAINT user_learn_histories_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.user_learn_histories DROP CONSTRAINT user_learn_histories_pkey;
       public                 postgres    false    234            �           2606    18093    user_learns user_learns_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.user_learns
    ADD CONSTRAINT user_learns_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.user_learns DROP CONSTRAINT user_learns_pkey;
       public                 postgres    false    232            �           2606    17999 "   user_personals user_personals_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.user_personals
    ADD CONSTRAINT user_personals_pkey PRIMARY KEY (id_user);
 L   ALTER TABLE ONLY public.user_personals DROP CONSTRAINT user_personals_pkey;
       public                 postgres    false    221            �           2606    18061    user_stacks user_stacks_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.user_stacks
    ADD CONSTRAINT user_stacks_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.user_stacks DROP CONSTRAINT user_stacks_pkey;
       public                 postgres    false    229            �           2606    17987    users users_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
       public                 postgres    false    220            �           2606    17985    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public                 postgres    false    220            �           2606    18045 -   project_stacks project_stacks_id_project_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.project_stacks
    ADD CONSTRAINT project_stacks_id_project_fkey FOREIGN KEY (id_project) REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY public.project_stacks DROP CONSTRAINT project_stacks_id_project_fkey;
       public               postgres    false    227    4775    224            �           2606    18050 +   project_stacks project_stacks_id_stack_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.project_stacks
    ADD CONSTRAINT project_stacks_id_stack_fkey FOREIGN KEY (id_stack) REFERENCES public.stacks(id) ON UPDATE CASCADE ON DELETE CASCADE;
 U   ALTER TABLE ONLY public.project_stacks DROP CONSTRAINT project_stacks_id_stack_fkey;
       public               postgres    false    226    4777    227            �           2606    18077 +   project_users project_users_id_project_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_id_project_fkey FOREIGN KEY (id_project) REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;
 U   ALTER TABLE ONLY public.project_users DROP CONSTRAINT project_users_id_project_fkey;
       public               postgres    false    224    230    4775            �           2606    18082 .   project_users project_users_id_user_stack_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_id_user_stack_fkey FOREIGN KEY (id_user_stack) REFERENCES public.user_stacks(id) ON UPDATE CASCADE ON DELETE CASCADE;
 X   ALTER TABLE ONLY public.project_users DROP CONSTRAINT project_users_id_user_stack_fkey;
       public               postgres    false    229    4781    230            �           2606    18023 "   projects projects_id_teamlead_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_id_teamlead_fkey FOREIGN KEY (id_teamlead) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.projects DROP CONSTRAINT projects_id_teamlead_fkey;
       public               postgres    false    4769    220    224            �           2606    18010 *   refresh_tokens refresh_tokens_id_user_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.refresh_tokens DROP CONSTRAINT refresh_tokens_id_user_fkey;
       public               postgres    false    4769    220    222            �           2606    18035    stacks stacks_id_direction_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stacks
    ADD CONSTRAINT stacks_id_direction_fkey FOREIGN KEY (id_direction) REFERENCES public.directions(id) ON UPDATE CASCADE ON DELETE CASCADE;
 I   ALTER TABLE ONLY public.stacks DROP CONSTRAINT stacks_id_direction_fkey;
       public               postgres    false    218    4765    226            �           2606    18111 7   user_learn_histories user_learn_histories_id_learn_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_learn_histories
    ADD CONSTRAINT user_learn_histories_id_learn_fkey FOREIGN KEY (id_learn) REFERENCES public.user_learns(id) ON UPDATE CASCADE ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.user_learn_histories DROP CONSTRAINT user_learn_histories_id_learn_fkey;
       public               postgres    false    4785    232    234            �           2606    18099 %   user_learns user_learns_id_stack_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_learns
    ADD CONSTRAINT user_learns_id_stack_fkey FOREIGN KEY (id_stack) REFERENCES public.stacks(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.user_learns DROP CONSTRAINT user_learns_id_stack_fkey;
       public               postgres    false    226    232    4777            �           2606    18094 $   user_learns user_learns_id_user_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_learns
    ADD CONSTRAINT user_learns_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 N   ALTER TABLE ONLY public.user_learns DROP CONSTRAINT user_learns_id_user_fkey;
       public               postgres    false    4769    220    232            �           2606    18000 *   user_personals user_personals_id_user_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_personals
    ADD CONSTRAINT user_personals_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.user_personals DROP CONSTRAINT user_personals_id_user_fkey;
       public               postgres    false    220    4769    221            �           2606    18067 %   user_stacks user_stacks_id_stack_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_stacks
    ADD CONSTRAINT user_stacks_id_stack_fkey FOREIGN KEY (id_stack) REFERENCES public.stacks(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.user_stacks DROP CONSTRAINT user_stacks_id_stack_fkey;
       public               postgres    false    226    4777    229            �           2606    18062 $   user_stacks user_stacks_id_user_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_stacks
    ADD CONSTRAINT user_stacks_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 N   ALTER TABLE ONLY public.user_stacks DROP CONSTRAINT user_stacks_id_user_fkey;
       public               postgres    false    4769    229    220            �           2606    17988    users users_id_direction_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_id_direction_fkey FOREIGN KEY (id_direction) REFERENCES public.directions(id) ON UPDATE CASCADE ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.users DROP CONSTRAINT users_id_direction_fkey;
       public               postgres    false    4765    218    220            T   �   x�=��
�@E뙯�Rŷ)D�PX،�!����3*��������`����1T5_�@��'�YC-�p
+2��r���{'gpd5N�w��8��+�Ƒ���S�renKBu�_B�� ��r����ٯ���"~ ;�-�      ]   �   x�%��� D�oSL�����:Bt�v�Xx?�����	ӳo���Y�K؄޻g�f0��`3�s���0�9�a1,`X���射%,a	KX��a�	&�`�	&X+X�
V���`=�akX�ְ��av�������w�UĔ����W�[�Sw��G���{��~�Z?��JY      `   B   x�-��	�0��TL��&v�������SQqެ؝º�����t���
���
*���ʹ2�>�      Z   �  x�͔Mo�0����k�v�n;��b@�ҋ"ӱZY4$�M�}� [�!�n��L�z��T��)`
���<�a�0�`'���F���"��5�'���~�#��9��}FOzi�e���~�F��◐�w	�AU�u{Y՗��͏��(��Tuq���;@>�-;��	�s��zI�a.X�v`{9P֊��.�9�Z2|GG��l���"��A���¨�{ț��Mq��zB�����QR���F�`QC�4n"�x�-s�d��E�7��4J��@��o�d4Q�v�p�gjN2�ō���y�m}� ��V=X�_"��r����S�//t���j�&��a�{�ɯI%�I���A�V��賹TE-m�ws螌��dv�R���C�w���D�LT [4o`(Y- ��ch$�f_��gj�eQ�'��2      X   �  x���ɒ���Ǘw��^"��
"]��N:-���OR������&|��f����N�<�ąQ��y�^�4K���s���_��@+�"��.8���u�]�\��<tU����ڬ���q�v�t+F�����O�l	_@��}W���n*C��J�Y�ͳ�j�DJ��u�>Q1F#2N(�����օ�H�Y���p}�l����0�y��	g�$��SzQGc�u	�q��8k����{IkF@4�3cF�B	��G����il#�p���{���W��yƛ�O]�����1��Z����><�1��֟��WÃ�j(&P��\��#�ڇ*hƣ1
c�VG}�:
���E���-��FPN�pX�Cj5+5�ԁ��He��D�
�ۙ�ff+��J�����w�Q��|�Rb��GJ�:b��1�@[�w}�9/�"o�E���;P�����t����.x��/<����������n��B~;J%:��iN¸�Yp5R��Y���$*���i˾�S��	b����b|)X�G>{ja���&y����K�N���	�c$��	P0I���<B̍��f���5��"���D��k����_�~���8c$ꦴ5$L���g
b9,
�m�&��+�����#)]���a�SPM�e��懘����闚�8j2XԜ��بl��T�yS�P�M̈����?j>c?���`$��yF�����EMco�ޜj�d�Ëg��Њn荤-�
ex�,��"�Fr��>
��k�0�e�k~=�QӔہ#R]k��}$��p�ͷ�2����#�"�`���̟�|0�C!�L�_�ͮ���9�Ǔom�1u�k���\UO#H�3L�xۛ>1'����r"�w�1��{*M�p��V�@٭��'��A�]�`2�1������y^B�9��/ߙ.߹k&��c[V�d�F 0
Յ�O]��]"�o̊������od"r��8�aK����/[��Ư7/����1
Յ�O]h�T�_.�`� 1)���3~5=�s'g�*k�Y`�_b��ǐ{XN���a�����̷E�*CL����i��K�ݖa�N'��#u _YB?��Mo�e0
Յ�O]�s|��leYH��9�U �P��U�?7�n������7��g&�z�(T*Q\H��,E7tw�l���=�q�=ܪ9h��	�Gu���Du�Ņ��}��R��v�����󚇽�a7��:ַ�:�<����X���|r*ф��L��"�Ψ�21��"iȁ��S���{y��'׻�F1�K+[yo	 N)gkEƥ� ����Yn'�^�I��;�S��A�an�w�Z&��Z�7Lf10���r��1E������5�I�j�>�GB��%����j+������U^�� �@�������%ݩuCG��Z�w]ur��&^�(cI��?9�n�#�����F���y5�.�;)o�䠀����c6�M���e����a�?��<      \   �  x�]��r�0E��WP5��d��^�G&�!q����eT����i�X��}��R߫� ,�]F�(��T[��9e5��ZQuD��m��Üb5M8&�t�����~P(�ne �D \}p�`�Uؖ��&?��5���U�X�[���m�#<���r!:֩,z�k�><�:�� V��aav(����G@J%��G��$�^��>�P�;��O�EGl�B��U�:0���jE�Nǰ]�����ؘ�7��Zs%hf���n���F$9�Xʬ�7r��?S��@��f�[��"q��9v@�:��5⟗�96l:^�&v �U�(ޅ.<*�2��wRa:���:���t�g8�=M�Mg2���W���G��._�%.>�g��\#�_
�O�6���b��Bf29�o�L�䂡����]t�=TW�=Ͳ���$����bu�R���Ȇ����s��S�n�1�t��7��i���B��\�����L�+d�����$l�Rj�BXт��kZsF�ć��7�7s-8�Ӧ�hS(fK�&�l�h�F�4�0+�nK��P�TԜ}[04|�)Y���\�JH�i�có���4�� ��/e)��ݏ6��s+�������٩3fp�q���.ģ����̥ܞ�B����5o׆a�����      d      x������ � �      b   �   x����m�@E�3U���6܊H�S��$�x����4t�`d}?07�",`&1�B��ɃtX|�ʠ�x�E�:�rG�E��u��A���c�FEN�yc��E��s�J�n��B��ߖ魠�Oѭ����*��@��z��q���@���5@؎|�y�BR��7�^��'��Jiq�R�h	���'�9_��\4      W   �  x���[o�F���_��t����� �i��S�`�&��ɀ���������\����@�ٳg�J6��������vw��C�7[��8��x�H΁qńZq�+��~�U�NY�X��$���ޯ��#��K��
��n��ol(���\��J�Ih��s�����?�l$�o���wn?�>�Ar	LH��1�j.������#6Wy\��X�f�2�W�CMү�R�Z��T��ql{\	���T��p��&X�Ey������y��a�^K��y���ś��?�u9�����ݖ9�AM7��u�5x`�2ckԈۡ��nد�8W�ϖG��)ѳJD*��ļ��R���$�Tȁ�r����ts���\��v3�v�m.�0��㥁馓KcX�}-�q�$�6��WB����$'cQ�	��**-k�t�Ȓ������~�ِ�ƶ��v{���vs�r-8p�{äb����ϩE�:z�V��q,�Dʊ�K����R��{� W7���s�����'��N� N�G�9rT<!z�bG�U���F��"���m���$�fؓN��0���d7����y^��nn۴��V<�#I�b�~��!3%x����3��e)�o~#���H�P�?���f�	-+�2�3Ι�J;s�G6AF$\��T���6�DTIJ��RX��W;��~ؐ�w�7W&������uN��T	�#\!��<g}!5��8'�\d*���a1�x\��毖�������dr�rVq���.�� �v�E�.}��>���k�[�+�O��;l�ıP�I��hӝĵ��Α��� ��VY�W�I�����:P��MI���:ӪG�˱��u�����<e�z�5���R<SCT�M*�!� \
�yK���;�.r����n���������&hÝ����3` `{��4i� ��v���ȌkRAoЦh,�դ��[��C���0s��Ĩz��y��
���屧'�d�݊�ձ=Ȁ��(YP�����`���� Y��6�u����K�|~n�����uu$&��1�@MY�g�@mk_��5�jՙxIYr��׋Q�OE� �E��h@T�R��_���Α��� ���j�Ni#X2��?�,di�&��.Ȱ�����")ޘT[4('/�-+BFgC�����O��c��o̊<�ɮP9S��\/<���JkI� E�y��y���)dY��,Rv���&��t~�=���|�KIG���t"�{�3o��H8�2S06�LcaN��܋�2�jJ0�iz�)��Ő%��N!QBF��P�w�QV.���S{����xݕ���, �%:� 5SF��T?oȢ�À���`�o�K�UP�H��X(K��,�O\��/O��ſ�[���ϋ㳣9Y�F�3=m~�w�����,P�R����W�^u���.�}�ۉ�ۏ����	�����<��kW���Ce�b^��69���u�׳������l,�K      _   �  x�=�A�!C��a� �]f�'���I5��DC�6�l�}�	����芜��p�;�'�q��AÅ�xz�W8:�Lc�8##�?w����X�:o�-뙺�#�MXUgë+uv\�?���5r��������t2/ 5>H�����~�U��ƣ��sY-�7�&y&�2��o����<�6�rl�&��FM�����i]�;�����b�\/Ť��2.˪�!��~%�&<	E���e-��83p_p�\"�u-����<_�\��#���+���M{}�XƇ&�^4�����nbI��X�ؕ#�)�~@��q%��F���ك�F`O�7�$���9['�T���r�֨�$���Q8��f�ș��OR��}�-󏾢�ߟ�y� �)�       V   %  x�mԹ�����X���@3��
��u�f���jr�:�j�Z�780�JD�=�M� +��]��_�`�?b%��Ey���Q����5����w���(�݂#;K��,�*��?,r���[��<�5ҟţp���t�'�Utf$r�76��M�um}p(������Vjd�]��\��o��|s�5�-%�P����19{}x�bb;�ovr�[���F�d�N�
_�
'�Z�ls�5)T�@o��|��X�n�٩���@��c�c�Ěb�Z7Y{�C5;�	E�Q�ܞ��Nݡ�<��X�I���[|o�+�����&��O���4Ez/ K�R'`�Ô<�3�?�~�����Wg�����}�n�kO��gI�&Z1�'0��Ӽ|獈-U|�uY�x��wTv���e���,I_y�10O���S�����\��Ǡr�AP�O�����=*��ɭ����R��f����t�Ex��(��ٵ�����|A��!nH�̾:��<��K�Ą+V��R�:;����XQbc�k&�1Μ����;��9�ڏ[���Ue�T�O%���H� ����ά�M(�ZhYw�~6I��w�AL`�x|�3[>&���-?�JmZP	�N̏�S|����53�Tx���~�Q����-�n��n�w����s�2�5^y̢���X�ƺ��j@$@R�����<��tqŨsn�����*߯�k�*�ޡ����)��{8UcC�~{ �`'X�m���#-���[�}c�	}(��쯠u��VP�g>�,�|o���N�⨋��`Az�+�j�r�ZdeХJ�͊�G���D���lG�ہ:��j�N�ϒ��%���H g��rTw�n儆�����=��_����&�?�[���c=����֓:��E������]w>�^��`q�bH�V�9�G�S.�I���i6�k"|+rV-$׷��Z�o�|q|pc���N'uh|}|']�Ӯ����� n�+1�hmV*�Lt��c.�%���QvJ��r`��N�`'^�t[��ϲڢ`Eu\)!�pF��7��;C* 9�Θ�Jl��?'^�S�{,���W����w>�,?y�臲�2�V&�MtR����ߩ���{ �.�_�}��}��K��˞�J�~IB-(td�5K����/��_q�� �-Q��j/|�5�<�(�����F���i�ܯ��Ux�/�����޿�/�3��|���F;<�s~U��P��nW�Ei}h��`I����;��;}e3�&i�|f*4S�j��#���Ek���>�y�#yID� 1���~��������     