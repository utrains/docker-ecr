resource "aws_ecr_repository" "ecr1" {
  name                 = "dev1"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags ={
    Env = "dev"
    Name = "ecr-repo"
  }
  
}