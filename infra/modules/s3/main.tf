resource "aws_s3_bucket" "mlops_handson" {
  bucket = "${var.prefix}-mlops-handson"
}
