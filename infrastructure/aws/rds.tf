data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "uddin" {
  vpc_id      = "${data.aws_vpc.default.id}"
  name        = "dbsicredi"
  description = "Allow all inbound for Mysql"
ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_instance" "mysql-sicredi" {
  identifier             = "mysql-dbsicredi"
  db_name                = "dbsicredi"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.uddin.id]
  username               = "root"
  password               = "senha123"
}

resource "null_resource" "db_setup" {
  depends_on = [aws_db_instance.mysql-sicredi]
  provisioner "local-exec" {    
    command = "mysql --host=${aws_db_instance.mysql-sicredi.address} --port=3306 --user=root --password=senha123 --database=dbsicredi < sql/db_structure.sql"
  }
}