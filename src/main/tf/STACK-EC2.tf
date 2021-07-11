resource "aws_efs_file_system" "EFS-mount" {
  tags = {
    Name = "EFS-mount"
  }
}
