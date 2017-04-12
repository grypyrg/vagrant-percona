class training::ssh_key {
	ssh_authorized_key { $title:
		ensure          => present,
		name            => 'xtradb-tutorial',
		user            => 'vagrant',
		type            => ssh-rsa,
		key             => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDXFysRRj+M3aOBIqw8dwtkdBHjyUwwGpGeIyB34VI02TENG85DwyGSmbDyuSWt30DRiRIh9h6h0Tv+yWAOJxGIqOAzxQN3Hn0HTdc3xZxNf+XbQztA8drAftHTshtr6A1/OWRdoVQ7++bAhuD5uXrtpiAW1VVst8jBoiyE7KT7MwVv/UXLVA+BFXo9bN9UGQ4SSryyZHGpMLnmPrlDzWkmsijXDjzkXZvJkB28wsEJGzem8a740z99gWYCHdPwx/tjLoCe4AvyaiaCQe3PtRYN/BZdw/i4d8aPATzbzE1VrLdK84zU9haTBP8rguWQS3hEGG3xGgso/W73nDPWJNlL"
	}
}
