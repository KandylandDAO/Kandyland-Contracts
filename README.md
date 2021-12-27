# Setup Audit

This is a setup intruction sheet to how a proper LBE should be launched and released to the public. Full contracts to be out in public and audited to be vetted before live launch. Make sure all functions below were run before presale is considered to be setup proper and within ownership of the multisig address and not in any developer ownership.

## Kandyland-Contracts

Kandy ERC20 Contract Adress: 0x37deD665a387a6f170FB60376B3057f09df6c0Ea

https://snowtrace.io/address/0x37deD665a387a6f170FB60376B3057f09df6c0Ea

Liquidity Bootstrap Event Contract Address: 0x90F2c25DDEe667931fcD2F0050D445CCe007b024

https://snowtrace.io/address/0x90F2c25DDEe667931fcD2F0050D445CCe007b024




## Deployment functions to be run on deployment before presale: 



### Kandy ERC20 Contract:

-setVault(DevWalletAddress) // Transfer vault ownership to dev to allow to mint

-mint(LBEContractAddress, 225000000000000) // Fund LBE contract with tokens for presale

-mint(DevWalletAddress, 25000000000000) // Fund Multisig Wallet with tokens for allocated marketing/dev/liquidity/misc funds

-setVault(Treasury Address/MultiSigAddress) // Transfer vault ownership to Treasury Address/Multisig

-transferOwnership(MultiSigAddress) // Transfer Policy/Owner ownership to multisig

Send Tokens from dev wallet to multisig address.


### Liquidity Bootstrap Event Contract:

-giveKandys(addressList, amountsList) // Submit addresses who previously purchased on old contract and credit them deserved tokens. (addressList = addresses.csv, amountsList = amounts.csv)

-disableGiveKandy() // Disable the ability to gift or credit any new addresses

-transferOwnership(MultiSigAddress) // Transfer Policy/Owner ownership to multisig


## Conclusion:

After all is done, no other functions were run, and verified. Can activate private sale. 
