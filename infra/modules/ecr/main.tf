resource "aws_ecr_repository" "ml_pipeline" {
  name                 = "${var.prefix}-mlops-handson/ml-pipeline"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "predict_api" {
  name                 = "${var.prefix}-mlops-handson/predict-api"
  image_tag_mutability = "MUTABLE"
}
