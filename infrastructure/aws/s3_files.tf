#resource "aws_s3_bucket_object" "job_spak" {
#  bucket = aws_s3_bucket.datalake.id
#  key    = "spark_code/spark-operator-processing-job-batch.py"
#  acl    = "private"
#  source = "../kubernates/spark/spark-operator-processing-job-batch.py"
#  etag   = filemd5("../kubernates/spark/spark-operator-processing-job-batch.py")
#}