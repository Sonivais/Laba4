-- DROP SCHEMA public;

CREATE SCHEMA public AUTHORIZATION pg_database_owner;

COMMENT ON SCHEMA public IS 'standard public schema';

-- DROP SEQUENCE doctors_id_doctors_seq;

CREATE SEQUENCE doctors_id_doctors_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 32767
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE doctors_id_doctors_seq OWNER TO postgres;
GRANT ALL ON SEQUENCE doctors_id_doctors_seq TO postgres;

-- DROP SEQUENCE patient_id_patient_seq;

CREATE SEQUENCE patient_id_patient_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 32767
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE patient_id_patient_seq OWNER TO postgres;
GRANT ALL ON SEQUENCE patient_id_patient_seq TO postgres;

-- DROP SEQUENCE reception_id_reception_seq;

CREATE SEQUENCE reception_id_reception_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 32767
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE reception_id_reception_seq OWNER TO postgres;
GRANT ALL ON SEQUENCE reception_id_reception_seq TO postgres;

-- DROP SEQUENCE specialization_doctors_id_specialization_seq;

CREATE SEQUENCE specialization_doctors_id_specialization_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 32767
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE specialization_doctors_id_specialization_seq OWNER TO postgres;
GRANT ALL ON SEQUENCE specialization_doctors_id_specialization_seq TO postgres;
-- public.patient определение

-- Drop table

-- DROP TABLE patient;

CREATE TABLE patient (
	id_patient smallserial NOT NULL,
	last_name varchar NULL,
	first_name varchar NULL,
	patronymic varchar NULL,
	date_birth date NULL,
	address varchar NULL,
	CONSTRAINT patient_pk PRIMARY KEY (id_patient)
);

-- Permissions

ALTER TABLE patient OWNER TO postgres;
GRANT ALL ON TABLE patient TO postgres;


-- public.specialization_doctors определение

-- Drop table

-- DROP TABLE specialization_doctors;

CREATE TABLE specialization_doctors (
	id_specialization smallserial NOT NULL,
	specialization varchar NULL,
	CONSTRAINT specialization_doctors_pk PRIMARY KEY (id_specialization)
);

-- Permissions

ALTER TABLE specialization_doctors OWNER TO postgres;
GRANT ALL ON TABLE specialization_doctors TO postgres;


-- public.doctors определение

-- Drop table

-- DROP TABLE doctors;

CREATE TABLE doctors (
	id_doctors smallserial NOT NULL,
	last_name varchar NULL,
	first_name varchar NULL,
	patronymic varchar NULL,
	id_specialization int2 NOT NULL,
	CONSTRAINT doctors_pk PRIMARY KEY (id_doctors),
	CONSTRAINT doctors_specialization_doctors_fk FOREIGN KEY (id_specialization) REFERENCES specialization_doctors(id_specialization) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table Triggers

create trigger calculate_doctor_salary_trigger before
insert
    or
update
    on
    public.doctors for each row execute function calculate_doctor_salary();

-- Permissions

ALTER TABLE doctors OWNER TO postgres;
GRANT ALL ON TABLE doctors TO postgres;


-- public.reception определение

-- Drop table

-- DROP TABLE reception;

CREATE TABLE reception (
	id_reception smallserial NOT NULL,
	id_patient int2 NOT NULL,
	id_doctors int2 NOT NULL,
	date_reception timestamp NULL,
	price_reception numeric NULL,
	percentage_salary numeric NULL,
	salary numeric NULL,
	CONSTRAINT reception_pk PRIMARY KEY (id_reception),
	CONSTRAINT reception_doctors_fk FOREIGN KEY (id_doctors) REFERENCES doctors(id_doctors) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT reception_patient_fk FOREIGN KEY (id_patient) REFERENCES patient(id_patient) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table Triggers

create trigger salary_trigger before
insert
    or
update
    on
    public.reception for each row execute function salary_check();

-- Permissions

ALTER TABLE reception OWNER TO postgres;
GRANT ALL ON TABLE reception TO postgres;



-- DROP FUNCTION public.calculate_doctor_salary();

CREATE OR REPLACE FUNCTION public.calculate_doctor_salary()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.salary := NEW.cost * NEW.commission_percentage;
    RETURN NEW;
END;
$function$
;

-- Permissions

ALTER FUNCTION public.calculate_doctor_salary() OWNER TO postgres;
GRANT ALL ON FUNCTION public.calculate_doctor_salary() TO postgres;

-- DROP FUNCTION public.salary_check();

CREATE OR REPLACE FUNCTION public.salary_check()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin 
	new.salary = new.price_reception * (new.percentage_salary/100) * 0.87;
return new;
end
$function$
;

-- Permissions

ALTER FUNCTION public.salary_check() OWNER TO postgres;
GRANT ALL ON FUNCTION public.salary_check() TO postgres;


-- Permissions

GRANT ALL ON SCHEMA public TO pg_database_owner;
GRANT USAGE ON SCHEMA public TO public; 

INSERT INTO public.doctors (id_doctors,last_name,first_name,patronymic,id_specialization) VALUES
	 (1,'Порванова','Света','Генадьевна',1),
	 (3,'Петров','Игорь','Александрович',10),
	 (4,'Никитин','Дмитрий','Олегович',5),
	 (5,'Иванов','Станислав','Михайлович',8),
	 (6,'Гиниятов','Адель','Тимурович',2),
	 (7,'Киселев','Артем','Андреевич',4),
	 (8,'Каратаева','Анастасия','Викторовна',9),
	 (9,'Казакова','Виктория','Алексеевна',3),
	 (10,'Бабушкина','Вера','Николаевна',6),
	 (11,'Рыбакова','Екатерина','Адреевна',7);
INSERT INTO public.patient (id_patient,last_name,first_name,patronymic,date_birth,address) VALUES
	 (1,'Садыков','Динар','Андреевич','2006-07-16','ул.Пушкина'),
	 (2,'Белкот','Софья','Александровна','2006-12-23','ул.Мира'),
	 (3,'Борисов','Тимофей','Олегович','2006-03-12','ул.Комсомольская'),
	 (4,'Помелов','Никита','Адександрович','2006-04-15','ул.Куйбышева'),
	 (5,'Анин','Павел','Алексеевич','2005-05-21','ул.Татарстана'),
	 (6,'Алексеев','Павел','Николаевич','2005-09-03','ул.Энгельса'),
	 (7,'Назарова','Дарья','Вячеславовна','2004-06-18','ул.Шоссейная'),
	 (8,'Шмелева','Татьяна','Алексеевна','2007-10-18','ул.Комарова'),
	 (9,'Старикова','Виктория','Станиславовна','2007-10-17','ул.Есенина'),
	 (10,'Хабибулин','Инсаф','Михаилович','2004-01-19','ул.Коралева');
INSERT INTO public.reception (id_reception,id_patient,id_doctors,date_reception,price_reception,percentage_salary,salary) VALUES
	 (2,4,3,'2024-11-30 11:30:00',4500,13,508.9500000000000000000000),
	 (1,1,6,'2024-12-04 12:00:00',1500,10,130.5000000000000000000000),
	 (3,3,8,'2024-12-01 09:00:00',2000,20,348.0000000000000000000000),
	 (4,8,1,'2024-11-27 10:00:00',1000,18,156.6000000000000000000000),
	 (5,6,10,'2024-11-30 09:00:00',3000,15,391.5000000000000000000000),
	 (10,5,11,'2024-12-02 09:30:00',1900,18,297.5400000000000000000000),
	 (11,2,9,'2024-12-05 13:00:00',500,10,43.5000000000000000000000),
	 (12,7,5,'2024-12-11 11:11:00',1999,27,469.5651000000000000000000),
	 (6,9,4,'2024-12-10 15:00:00',2500,14,304.5000000000000000000000),
	 (7,10,7,'2024-12-01 10:00:00',5000,18,783.0000000000000000000000);
INSERT INTO public.specialization_doctors (id_specialization,specialization) VALUES
	 (1,'Офтальмолог'),
	 (2,'Хирург'),
	 (3,'Педиатор'),
	 (4,'Дерматолог'),
	 (5,'Диетолог'),
	 (6,'Нефролог'),
	 (7,'Ортопед'),
	 (8,'Психиатр'),
	 (9,'Стоматолог'),
	 (10,'Кардиолог');
