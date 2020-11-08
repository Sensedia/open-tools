resource "aws_key_pair" "my_key"{
  key_name   = var.aws_key_name
  public_key = file(var.aws_public_key_path)
}