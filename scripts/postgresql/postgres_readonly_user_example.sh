psql template1
create user userdb password 'userdb';
alter user userdb set default_transaction_read_only = on;
\q

psql userdb
grant connect on database "database" to userdb;
grant usage on schema public to userdb;
grant select on all tables in schema public to userdb;
alter default privileges in schema public grant select on tables to userdb;
\q
