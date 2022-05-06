resource "aws_s3_bucket" "datalake" {
  # Parâmetros de configuração do recurso escolhido
  bucket = "${var.base_bucket_name}"
  
  tags = {
    DESAFIO  = "Sicredi"
    TIPO = "Geração de arquivo flat"
  }
}

resource "aws_s3_bucket_acl" "datalake" {
  bucket = aws_s3_bucket.datalake.id  
  acl    = "private"

}

resource "aws_s3_bucket_server_side_encryption_configuration" "datalake" {
  bucket = aws_s3_bucket.datalake.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


