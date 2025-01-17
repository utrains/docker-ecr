resource "aws_iam_role" "docker_ecr_role" {
  name = "docker-ecr2025"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin_policy_attachment" {
  role       = aws_iam_role.docker_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "docker_ecr_profile" {
  name = "deckerecrprofile"
  role = aws_iam_role.docker_ecr_role.name
}