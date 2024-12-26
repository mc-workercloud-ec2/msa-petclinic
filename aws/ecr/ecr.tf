resource "aws_ecr_repository" "ecr_frontend" {
    name = "${var.container_name}-frontend"
}

resource "aws_ecr_repository" "ecr_backend" {
    name = "${var.container_name}-backend"
}