class test::sysbench_load(
	$tables = 1,
	$rows = 250000,
	$threads = 1,
	$schema = 'sbtest',
	$engine = 'innodb'
) {
	exec { 
		'create_schema':
			command => "/usr/bin/mysqladmin create $schema",
			cwd => '/root',
			creates => "/var/lib/mysql/$schema/";
		'prepare_database':
			command => "sysbench --test=sysbench_tests/db/parallel_prepare.lua --db-driver=mysql --mysql-table-engine=$engine --mysql-user=root --mysql-db=$schema --oltp-tables-count=$tables --oltp-table-size=$rows --oltp-auto-inc=off --max-requests=$threads --num-threads=$threads run",
			timeout => 0,  # unlimited
			logoutput => 'on_failure',
			path => ['/usr/bin', '/bin', '/usr/local/bin'],
			cwd => '/root',
			creates => "/var/lib/mysql/$schema/sbtest$tables.frm",
			require => Exec['create_schema'];
	}


}
