-include .env

build:; forge build

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

get-prompt:
	code2prompt . --exclude="*/lib/**,*/out/**,*/cache/**,*/test/**,*.env,*.hbs,*.gitignore,*gitmodules,*.png,.*.md,*.txt,*.min.js" --exclude-from-tree --tokens --output=output.txt
