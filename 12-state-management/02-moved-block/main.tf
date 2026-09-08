resource "random_pet" "app_identity" {
  length = 2
}

moved {
  from = random_pet.service_identity
  to   = random_pet.app_identity
}
