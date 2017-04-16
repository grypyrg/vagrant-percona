#!/usr/bin/perl

# setup all nodes in replication with the first node in `vagrant status` as the master.

print "Setup nodes with replication:\n";
print "\nDiscovering running VMs:\n";

my @running_nodes_lines = `vagrant status 2>/dev/null | grep running`;
my @running_nodes;
foreach my $line( @running_nodes_lines ) {
	if( $line =~ m/^(\w+)\s+\w+\s+\((\w+)\)$/ ) {
		push( @running_nodes, {
			name => $1,
			provider => $2
		});
	}
}

# Harvest node ips
foreach my $node( @running_nodes ) {
	my $nic = 'eth1';
	$nic = 'eth0' if $node->{provider} eq 'aws';

	my $ip_str = `vagrant ssh $node->{name} -c "ip a l | grep $nic | grep inet" 2>/dev/null`;
	if( $ip_str =~ m/inet\s(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\// ) {
		$node->{ip} = $1;
		print "Found node: $node->{name} ($node->{ip})\n";
	}
}

# use Data::Dumper qw( Dumper );
# print Dumper( @running_nodes );

my $master = shift @running_nodes;
my $master_ip = $master->{ip};

print "\nMaster node will be: $master->{name} ($master->{ip})\n";

# Get master's most recent binlog file
my $master_status =<<END;
mysql --batch -e \\"show binary logs\\" | tail -n 1
END

my @master_status_str = `vagrant ssh $master->{name} -c \"$master_status\" 2>/dev/null`;
my $master_log_file;
my $master_log_pos = 0;

# This is just a sanity check
if( $master_status_str[$#master_status_str] =~ m/^(.+)\s+(\d+)/ ) {
	$master_log_file = $1;
	$master_log_pos = $2;
} else {
	die "Could not parse master log file and position!\n";
}

# Override the position. We need to capture everything that may have
# been initialized on the master during its provisioning. Otherwise
# we immediately start with invalid slaves.
$master_log_pos = 4;

# Report master status
print <<END;
Replication coordinates:
	master_host='$master_ip'
	master_log_file='$master_log_file'
	master_log_pos=$master_log_pos

END

# Setup slave user:
my $grant =<<END;
mysql -e \\"GRANT REPLICATION SLAVE ON *.* TO 'repl'\@'%' IDENTIFIED BY 'repl'\\"
END
print "Setting up 'repl' user on $master->{name}\n";
print "- $grant\n";
system( "vagrant ssh $master->{name} -c \"$grant\" 2>/dev/null" );

# Configure the slaves
my $change_master =<<END;
mysql -e \\"CHANGE MASTER TO master_host='$master_ip', master_log_file='$master_log_file', master_log_pos=$master_log_pos, master_user='repl', master_password='repl'; start slave;\\"
END

foreach my $slave( @running_nodes ) {
	print "Executing CHANGE MASTER and START SLAVE on '$slave->{name}':\n";
	print "- $change_master\n";
	system( "vagrant ssh $slave->{name} -c \"$change_master\" 2>/dev/null");
}
