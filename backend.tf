terraform {
  backend "s3" {
    bucket         = "terraform123456789yash"
    key            = "tf/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true   # Optional: Enable encryption
  
  }
}
