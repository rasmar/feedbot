pack:
	pushd source && zip -r ../temp/source.zip * && popd
terraform:
	terraform apply
push: pack terraform
