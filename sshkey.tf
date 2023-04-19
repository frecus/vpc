
# specify ssh public key
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"
  key_name   = "key-test"
  public_key = "random ssh public key"
}
