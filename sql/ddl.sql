create type public.rating as enum ('good', 'okay', 'bad');
create type public.carfree as enum ('Yes', 'No', 'Maybe');
create type public.jurisdiction as enum ('federal', 'province', 'city', 'social');

create sequence public.city_id_seq;
create sequence public.country_id_seq;
create sequence public.province_id_seq;
create sequence public.tax_id_seq;

create table public.region (
  name text primary key not null
);

create table public.currency (
  id text primary key not null,
  exchange_rate_usd numeric not null
);

create table public.country (
  id integer primary key not null default nextval('country_id_seq'::regclass),
  name text not null,
  freedom_index numeric(3,2) not null,
  english_speaking_percent integer not null,
  unemployment_percent numeric(3,1) not null,
  region text not null,
  foreign key (region) references public.region (name)
  match simple on update no action on delete no action
);
create unique index country_name_key on country using btree (name);

create table public.province (
  id integer primary key not null default nextval('province_id_seq'::regclass),
  name text not null,
  country_id integer not null,
  foreign key (country_id) references public.country (id)
  match simple on update no action on delete cascade
);

create table public.city (
  id integer primary key not null default nextval('city_id_seq'::regclass),
  name text not null,
  human_development_index numeric(4,3) not null,
  quality_of_life_index numeric,
  crime_index numeric(4,2),
  health_care_index numeric(4,2),
  air_quality_index rating,
  population numeric not null,
  density_per_km numeric not null,
  car_free_status carfree,
  average_month_salary numeric not null,
  cost_of_living numeric,
  rent_studio_average numeric,
  rent_1_bedroom_average numeric,
  max_temperature_during_winter numeric,
  min_temperature_during_winter numeric,
  max_temperature_during_spring numeric,
  min_temperature_during_spring numeric,
  max_temperature_during_summer numeric,
  min_temperature_during_summer numeric,
  max_temperature_during_autumn numeric,
  min_temperature_during_autumn numeric,
  province_id numeric not null
);


create table public.tax (
  id integer primary key not null default nextval('tax_id_seq'::regclass),
  jurisdiction jurisdiction,
  city_id integer,
  province_id integer,
  country_id integer,
  percent_from numeric not null,
  percent_to numeric,
  tax_from numeric,
  currency text not null,
  fixed_tax numeric,
  foreign key (city_id) references public.city (id)
  match simple on update no action on delete no action,
  foreign key (country_id) references public.country (id)
  match simple on update no action on delete no action,
  foreign key (currency) references public.currency (id)
  match simple on update no action on delete no action,
  foreign key (province_id) references public.province (id)
  match simple on update no action on delete no action
);
alter table tax add column tax_limit numeric;
alter table tax add column income_floor numeric;