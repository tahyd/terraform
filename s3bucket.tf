

terraform{
    required_providers {

        aws = {
 source = "hashicorp/aws"
         version = "~> 5.0"
        }
        
    }

}

'


provider "aws" {
    region = "us-east-1"
   
}



resource "aws_s3_bucket" "sample_bucket" {
    bucket = "sample-demo-bucket-12345"
     tags = {
        Name = "sample_bucket1108679044"
        Description = "Sample bucket to store terraform state file"
     }
}

resource "aws_s3_object" "sample_object" {

    content = "<h1> Hello World ! </h1>"
    key = "sample.txt"
    bucket = aws_s3_bucket.sample_bucket.id
}

resource "aws_s3_bucket_public_access_block" "example" {
       bucket = aws_s3_bucket.sample_bucket.id
      block_public_acls = false
      block_public_policy = false
      ignore_public_acls = false
      restrict_public_buckets = false
    }

resource "aws_s3_bucket_policy" "s3-policy" {
   bucket = aws_s3_bucket.sample_bucket.id
   policy = <<EOF
       
  
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.sample_bucket.id}/*",
            "Principal" : "*"
        }
    ]
}




    EOF
}

