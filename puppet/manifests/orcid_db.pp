Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

class {
  orcid_base::postgresql:
  
    version => "9.5",
    
    hba     => "
local   all             postgres                                peer
local   all             all                                     peer
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
    ",
    
    conf    => "
data_directory             = '/var/lib/postgresql/9.5/main'
hba_file                   = '/etc/postgresql/9.5/main/pg_hba.conf'
ident_file                 = '/etc/postgresql/9.5/main/pg_ident.conf'
external_pid_file          = '/var/run/postgresql/9.5-main.pid'
port                       = 5432
max_connections            = 100
unix_socket_directories    = '/var/run/postgresql'
ssl                        = true
ssl_cert_file              = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
ssl_key_file               = '/etc/ssl/private/ssl-cert-snakeoil.key'
shared_buffers             = 128MB
dynamic_shared_memory_type = posix
log_line_prefix            = '%t [%p-%l] %q%u@%d '
log_timezone               = 'UTC'
cluster_name               = '9.5/main'
stats_temp_directory       = '/var/run/postgresql/9.5-main.pg_stat_tmp'
datestyle                  = 'iso, mdy'
timezone                   = 'UTC'
lc_messages                = 'en_US.UTF-8'
lc_monetary                = 'en_US.UTF-8'
lc_numeric                 = 'en_US.UTF-8'
lc_time                    = 'en_US.UTF-8'
default_text_search_config = 'pg_catalog.english'    
    "  
}
