pack:
	rm -f temp/s* && pushd source && zip -r -q ../temp/source.zip * && popd
terraform:
	terraform apply
push: pack terraform
