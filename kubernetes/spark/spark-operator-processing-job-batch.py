# import libraries
from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession
import os

aws_access_key_id = os.environ['AWS_ACCESS_KEY_ID']
aws_secret_access_key = os.environ['AWS_SECRET_ACCESS_KEY']

caminhoS3 = "s3a://datalake-sicredi/processing/movimentacao-conta/"

conf = (
SparkConf()    
    .set("spark.hadoop.fs.s3a.access.key", aws_access_key_id)
    .set("spark.hadoop.fs.s3a.secret.key", aws_secret_access_key)    
    .set("spark.hadoop.fs.s3a.fast.upload", True)    
    .set("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
    .set('spark.executor.extraJavaOptions','-Dcom.amazonaws.services.s3.enableV4=true')
    .set('spark.driver.extraJavaOptions','-Dcom.amazonaws.services.s3.enableV4=true')    
    .set("spark.jars.packages", "org.apache.hadoop:hadoop-aws:2.7.3, mysql:mysql-connector-java:8.0.17")        
)

# apply config
sc = SparkContext(conf=conf).getOrCreate()
sc.setSystemProperty('com.amazonaws.services.s3.enableV4', 'true')

# main spark program
if __name__ == '__main__':

    # init spark session
    # name of the app
    spark = SparkSession \
            .builder \
            .appName("processing-job-batch") \
            .getOrCreate()

    # set log level to info
    spark.sparkContext.setLogLevel("WARN")
    
    df = (
        spark.read
        .format("jdbc")
        .option("url", "jdbc:mysql://mysql-dbsicredi.cj3zxuvuqyti.us-east-2.rds.amazonaws.com/dbsicredi")        
        .option("query","select * from vw_movimento_flat")
        .option("user","root")
        .option("password","senha123")
        .load()
    )
    print("Caminho S3: " + caminhoS3)
    df.show()
    df.printSchema()

    (
    df    
    .write.mode('overwrite')    
    .format('csv')
    .option("header",True)
    .option("delimiter", ";")
    .save(caminhoS3)    
    )

    print("*******************************")
    print("Arquivo CSV Gerado com sucesso!")
    print("*******************************")
    
    # stop spark session
    spark.stop()